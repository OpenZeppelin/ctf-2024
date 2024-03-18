# `CREATE` Factory

[![🕵️‍♂️ Test smart contracts](https://github.com/pcaversaccio/create-util/actions/workflows/test-contracts.yml/badge.svg)](https://github.com/pcaversaccio/create-util/actions/workflows/test-contracts.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/license/mit/)

Helper smart contract [`Create`](./contracts/Create.sol) to make easier and safer usage of the [`CREATE`](https://www.evm.codes/#f0) Ethereum Virtual Machine (EVM) opcode. `CREATE`, in a way, does a built-in call. What actually happens is that the data passed to that call isn't the contract bytecode, it's the **init bytecode** (a.k.a. creation bytecode).

When the `CREATE` opcode is executed, the EVM creates a call frame in the context of the new contract (e.g. `address(this)` is the new contract's address). This executes the data passed to `CREATE` as the code, which in higher level languages is basically the constructor. At the end of this init stuff, it returns the actual code of the contract that is stored in the state trie.

The easiest way to think about it, which is also fairly accurate, is that the Solidity compiler takes all the executional code of the contract, compiles it to bytecode, and adds it as a return statement at the end of the constructor.

The smart contract [`Create`](./contracts/Create.sol) also provides a function `computeAddress` that returns (via the Recursive Length Prefix (RLP) encoding scheme) the address where a contract will be stored if deployed via `CREATE`.

## Test Deployments

- Goerli: [`0x39E77F0B8738CE04c00361D3b24368Cd2dd0457F`](https://goerli.etherscan.io/address/0x39E77F0B8738CE04c00361D3b24368Cd2dd0457F)
- Sepolia: [`0x39E77F0B8738CE04c00361D3b24368Cd2dd0457F`](https://sepolia.etherscan.io/address/0x39E77F0B8738CE04c00361D3b24368Cd2dd0457F)
- zkSync Era Testnet (Goerli): [`0xaFD8FbD7Ec35dd3149a410d3a7dD86c1fA197B70`](https://goerli.explorer.zksync.io/address/0xaFD8FbD7Ec35dd3149a410d3a7dD86c1fA197B70)

## `CREATE2` Factory

A helper smart contract to make easier and safer usage of the [`CREATE2`](https://eips.ethereum.org/EIPS/eip-1014) EVM opcode can be found [here](https://github.com/pcaversaccio/create2deployer).
