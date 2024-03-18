import os
import json
import asyncio

from starknet_py.net.account.account import Account
from starknet_py.net.full_node_client import FullNodeClient
from starknet_py.net.models.chains import StarknetChainId
from starknet_py.net.signer.stark_curve_signer import KeyPair
from starknet_py.contract import Contract
from starknet_py.common import create_casm_class, create_sierra_compiled_contract
from starknet_py.hash.casm_class_hash import compute_casm_class_hash
from starknet_py.hash.sierra_class_hash import compute_sierra_class_hash

client = FullNodeClient(node_url=os.getenv('RPC_URL'))
account = Account(
    client=client,
    address=os.getenv('ACCOUNT_ADDRESS'),
    key_pair=KeyPair.from_private_key(
        key=os.getenv('PRIVATE_KEY')),
    chain=StarknetChainId.TESTNET,
)


async def check_if_already_declared(account, sierra_class_hash):
    print("Checking if contract is already declared...")
    try:
        await account.client.get_class_by_hash(sierra_class_hash)
        print("Contract already declared.")
        return True
    except Exception:
        print("Contract not declared yet.")
        return False


async def declare_contract(
    account, casm_compiled_contract, sierra_compiled_contract, max_fee
):
    print("Declaring contract...")
    casm_class = create_casm_class(casm_compiled_contract)
    casm_class_hash = compute_casm_class_hash(casm_class)

    print(f"Casm class hash: {hex(casm_class_hash)}")

    sierra_class_hash = get_sierra_class_hash(sierra_compiled_contract)
    if await check_if_already_declared(account, sierra_class_hash):
        print("Contract was already declared. No declaration needed.")
        return

    print("Sending transaction...")
    declare_v2_transaction = await account.sign_declare_v2_transaction(
        compiled_contract=sierra_compiled_contract,
        compiled_class_hash=casm_class_hash,
        max_fee=int(1e18),
    )

    resp = await account.client.declare(transaction=declare_v2_transaction)
    print(f"Transaction hash: {hex(resp.transaction_hash)}")

    print(f"Sierra class hash: {hex(sierra_class_hash)}")
    print("Contract declared successfully.")


def get_sierra_class_hash(compiled_contract_str: str) -> int:
    sierra_compiled_contract = create_sierra_compiled_contract(
        compiled_contract_str)
    return compute_sierra_class_hash(sierra_compiled_contract)


async def declare_and_deploy_contract(
    account,
    casm_compiled_contract,
    sierra_compiled_contract,
    max_fee
):
    await declare_contract(
        account, casm_compiled_contract, sierra_compiled_contract, max_fee
    )
    sierra_class_hash = get_sierra_class_hash(sierra_compiled_contract)
    await deploy_contract(
        account, sierra_compiled_contract, sierra_class_hash, max_fee
    )


async def deploy_contract(
    account, sierra_compiled_contract_str, class_hash, max_fee
):
    print("Deploying contract...")
    sierra_compiled_contract = create_sierra_compiled_contract(
        sierra_compiled_contract_str
    )
    abi = sierra_compiled_contract.abi

    deploy_result = await Contract.deploy_contract(
        account=account,
        class_hash=class_hash,
        abi=json.loads(abi),
        max_fee=int(1e18),
        cairo_version=1,
    )

    contract = deploy_result.deployed_contract
    print(
        f"Contract deployed successfully at address: {hex(contract.address)}"
    )


casm_file = "target/dev/ctf_GreedySadMan.compiled_contract_class.json"
sierra_file = "target/dev/ctf_GreedySadMan.contract_class.json"

with open(casm_file, "r") as casm_file:
    casm_compiled_contract = casm_file.read()

with open(sierra_file, "r") as sierra_file:
    sierra_compiled_contract = sierra_file.read()

asyncio.run(declare_and_deploy_contract(
    account=account,
    casm_compiled_contract=casm_compiled_contract,
    sierra_compiled_contract=sierra_compiled_contract,
    max_fee=int(100e18)
))
