// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
    function approve(address spender, uint256 amount) external returns (bool);
}
