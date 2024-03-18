// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PriceFeed {
    function fetchPrice() external pure returns (uint256, uint256) {
        return (2207 ether, 0.01 ether);
    }
}
