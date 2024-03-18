// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-ctf/CTFDeployment.sol";

import {Challenge} from "src/Challenge.sol";
import {Token} from "src/Token.sol";
import {Forwarder} from "src/Forwarder.sol";
import {Staking} from "src/Staking.sol";

contract Deploy is CTFDeployment {
    function deploy(address system, address player) internal override returns (address challenge) {
        vm.startBroadcast(system);

        Token token = new Token("Staking", "STK", 100 * 10 ** 18);
        Token reward = new Token("Reward", "RWD", 100_000_000 * 10 ** 18);

        Forwarder forwarder = new Forwarder();

        Staking staking = new Staking(token, reward, address(forwarder));

        staking.setRewardsDuration(20);
        reward.transfer(address(staking), reward.totalSupply());
        token.transfer(player, token.totalSupply());

        challenge = address(new Challenge(staking, forwarder));

        vm.stopBroadcast();
    }
}
