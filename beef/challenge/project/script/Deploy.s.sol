// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-ctf/CTFDeployment.sol";

import "src/Challenge.sol";
import "src/Beef.sol";

import "openzeppelin/utils/Strings.sol";

contract Deploy is CTFDeployment {
    function deploy(address system, address) internal override returns (address challenge) {
        vm.startBroadcast(system);

        Beef beef = new Beef("beef", "BEEF", system);

        challenge = address(new Challenge(beef));

        vm.stopBroadcast();

        string memory env = "PRIVATE_KEY_";

        for (uint256 i = 0; i < 2; i++) {
            uint256 userKey = vm.envUint(string.concat(env, Strings.toString(i)));
            address user = vm.addr(userKey);

            vm.startBroadcast(system);
            beef.mint(address(user), 100);
            payable(user).transfer(1 ether);
            vm.stopBroadcast();

            vm.broadcast(userKey);
            beef.approve(address(beef), 100);
        }
    }
}
