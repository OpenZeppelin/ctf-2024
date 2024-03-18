// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Staking} from "src/Staking.sol";
import {Forwarder} from "src/Forwarder.sol";

contract Challenge {
    Staking public immutable staking;
    Forwarder public immutable forwarder;

    constructor(Staking _staking, Forwarder _forwarder) {
        staking = _staking;
        forwarder = _forwarder;
    }

    function isSolved() external view returns (bool) {
        uint256 amazingNumber = 1128120030438127299645800;
        return
            staking.earnedTotal() >= amazingNumber && staking.rewardsToken().balanceOf(address(0x123)) >= amazingNumber;
    }
}
