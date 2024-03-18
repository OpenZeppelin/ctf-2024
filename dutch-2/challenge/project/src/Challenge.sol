// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {AuctionManager} from "src/AuctionManager.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract Challenge {
    AuctionManager public immutable auction;
    ERC20 public immutable quoteToken;
    ERC20 public immutable baseToken;

    constructor(AuctionManager _auction, ERC20 _quoteToken, ERC20 _baseToken) {
        auction = _auction;
        quoteToken = _quoteToken;
        baseToken = _baseToken;
    }

    function isSolved() external view returns (bool) {
        return quoteToken.balanceOf(address(auction)) == 0;
    }
}
