// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Beef} from "src/Beef.sol";

contract Challenge {
    Beef public immutable BEEF;

    constructor(Beef beef) {
        BEEF = beef;
    }

    function isSolved() external view returns (bool) {
        return BEEF.totalSupply() == 0;
    }
}
