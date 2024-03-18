// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {ManagerAccess} from "src/helpers/ManagerAccess.sol";

contract Token is ERC20, ManagerAccess {
    constructor(address _manager, string memory _id) ERC20(_id, _id) ManagerAccess(_manager) {}

    function mint(address to, uint256 amount) external onlyManager {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyManager {
        _burn(from, amount);
    }
}
