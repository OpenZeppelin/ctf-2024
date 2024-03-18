// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-ctf/CTFDeployment.sol";

import {Challenge} from "src/Challenge.sol";

import {IAuction} from "src/interfaces/IAuction.sol";
import {IWETH} from "src/interfaces/IWETH.sol";
import {IERC721Extended} from "snekmate/test/tokens/interfaces/IERC721Extended.sol";

contract Deploy is CTFDeployment {
    function deploy(address system, address) internal override returns (address challenge) {
        vm.startBroadcast(system);

        IWETH weth = IWETH(deploy("src/", "WETH", ""));

        bytes memory args = abi.encode(system);
        IERC721Extended art = IERC721Extended(deploy("src/", "Art", args));

        args = abi.encode(1 ether, 1 ether / uint256(7 days), art, 0, address(weth));
        IAuction auction = IAuction(deploy("src/", "Auction", args));

        weth.deposit{value: 1 ether}();
        weth.approve(address(auction), 1 ether);

        art.safe_mint(address(auction), "https://ctf.openzeppelin.com");

        challenge = address(new Challenge(art, auction, system));

        vm.stopBroadcast();
    }

    function deploy(string memory path, string memory name, bytes memory args)
        internal
        returns (address deployedAddress)
    {
        string[] memory cmds = new string[](2);
        cmds[0] = "/usr/local/bin/vyper";
        cmds[1] = string.concat(path, name, ".vy");

        bytes memory bytecode = vm.ffi(cmds);
        bytecode = abi.encodePacked(bytecode, args);

        assembly ("memory-safe") {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(deployedAddress != address(0), "Deployment failed");
    }
}
