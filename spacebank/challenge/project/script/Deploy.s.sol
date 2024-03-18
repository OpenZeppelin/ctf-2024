// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-ctf/CTFDeployment.sol";

import "src/Challenge.sol";
import "src/SpaceBank.sol";

contract Deploy is CTFDeployment {
    function deploy(address system, address) internal override returns (address challenge) {
        vm.startBroadcast(system);

        SpaceToken token = new SpaceToken();

        SpaceBank spacebank = new SpaceBank(address(token));

        token.mint(address(spacebank), 1000);

        challenge = address(new Challenge(spacebank));

        vm.stopBroadcast();
    }
}
