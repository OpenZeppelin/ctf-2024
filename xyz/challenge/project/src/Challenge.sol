// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Token} from "src/Token.sol";
import {Manager} from "src/Manager.sol";

contract Challenge {
    Token public immutable xyz;
    Token public immutable seth;
    Manager public immutable manager;

    constructor(Token _xyz, Token _seth, Manager _manager) {
        xyz = _xyz;
        seth = _seth;
        manager = _manager;
    }

    function isSolved() external view returns (bool) {
        return xyz.balanceOf(address(0xCAFEBABE)) == 250_000_000 ether;
    }
}
