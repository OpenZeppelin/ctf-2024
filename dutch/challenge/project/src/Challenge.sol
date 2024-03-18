// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IAuction} from "src/interfaces/IAuction.sol";
import {IERC721Extended} from "snekmate/test/tokens/interfaces/IERC721Extended.sol";

contract Challenge {
    IERC721Extended public immutable art;
    IAuction public immutable auction;
    address public immutable user;

    constructor(IERC721Extended _art, IAuction _auction, address _user) {
        art = _art;
        auction = _auction;
        user = _user;
    }

    function isSolved() external view returns (bool) {
        return art.balanceOf(address(auction)) == 0;
    }
}
