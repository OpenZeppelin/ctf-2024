// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-ctf/CTFDeployment.sol";

import {Challenge} from "src/Challenge.sol";
import {AuctionManager} from "src/AuctionManager.sol";
import {Token} from "src/Token.sol";

contract Deploy is CTFDeployment {
    function deploy(address system, address player) internal override returns (address challenge) {
        vm.startBroadcast(system);

        Token quoteToken = new Token("USD Coin", "USDC", 6);
        Token baseToken = new Token("Wrapped Ethereum", "WETH", 18);

        AuctionManager auction = new AuctionManager();

        quoteToken.mint(address(auction), 10000 * 1e6);
        baseToken.mint(address(auction), 100 * 1e18);

        quoteToken.mint(player, 100 ether);
        baseToken.mint(player, 100 ether);

        challenge = address(new Challenge(auction, quoteToken, baseToken));

        vm.stopBroadcast();
    }
}
