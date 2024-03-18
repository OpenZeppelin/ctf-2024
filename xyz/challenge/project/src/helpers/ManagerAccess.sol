// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract ManagerAccess {
    address public immutable manager;

    error Unauthorized(address caller);

    modifier onlyManager() {
        if (msg.sender != manager) {
            revert Unauthorized(msg.sender);
        }
        _;
    }

    constructor(address _manager) {
        manager = _manager;
    }
}
