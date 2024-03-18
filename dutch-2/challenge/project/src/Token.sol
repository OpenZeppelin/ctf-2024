// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract Token is ERC20 {
    address owner;

    constructor(string memory name, string memory symbol, uint8 decimals) ERC20(name, symbol, decimals) {
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner);
        _mint(to, amount);
    }
}
