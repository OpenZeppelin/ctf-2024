// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-ctf/CTFDeployment.sol";

import {Challenge} from "src/Challenge.sol";
import {Manager} from "src/Manager.sol";
import {PriceFeed} from "src/PriceFeed.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Token} from "src/Token.sol";
import {ERC20Signal} from "src/ERC20Signal.sol";

contract Deploy is CTFDeployment {
    function deploy(address system, address player) internal override returns (address challenge) {
        vm.startBroadcast(system);

        Token sETH = new Token(system, "sETH");
        Manager manager = new Manager();
        Token XYZ = manager.xyz();
        challenge = address(new Challenge(XYZ, sETH, manager));

        manager.addCollateralToken(IERC20(address(sETH)), new PriceFeed(), 20_000_000_000_000_000 ether, 1 ether);

        sETH.mint(system, 2 ether);
        sETH.approve(address(manager), type(uint256).max);
        manager.manage(sETH, 2 ether, true, 3395 ether, true);

        (, ERC20Signal debtToken,,,) = manager.collateralData(IERC20(address(sETH)));
        manager.updateSignal(debtToken, 3520 ether);

        sETH.mint(player, 6000 ether);

        vm.stopBroadcast();
    }
}
