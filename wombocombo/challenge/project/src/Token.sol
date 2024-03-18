// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor(string memory _name, string memory _symbol, uint256 amount) ERC20(_name, _symbol) {
        _mint(msg.sender, amount);
    }
}
