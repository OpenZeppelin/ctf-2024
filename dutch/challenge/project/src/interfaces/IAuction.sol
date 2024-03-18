// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IAuction {
    function buyWithPermit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
