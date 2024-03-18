// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";

import {ManagerAccess} from "src/helpers/ManagerAccess.sol";
import {ProtocolMath} from "src/helpers/ProtocolMath.sol";

contract ERC20Signal is ERC20, ManagerAccess {
    using ProtocolMath for uint256;

    uint256 public signal;

    constructor(address _manager, uint256 _signal, string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
        ManagerAccess(_manager)
    {
        signal = _signal;
    }

    function mint(address to, uint256 amount) external onlyManager {
        _mint(to, amount.divUp(signal));
    }

    function burn(address from, uint256 amount) external onlyManager {
        _burn(from, amount == type(uint256).max ? ERC20.balanceOf(from) : amount.divUp(signal));
    }

    function setSignal(uint256 backingAmount) external onlyManager {
        uint256 supply = ERC20.totalSupply();
        uint256 newSignal = (backingAmount == 0 && supply == 0) ? ProtocolMath.ONE : backingAmount.divUp(supply);
        signal = newSignal;
    }

    function totalSupply() public view override returns (uint256) {
        return ERC20.totalSupply().mulDown(signal);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return ERC20.balanceOf(account).mulDown(signal);
    }

    function transfer(address, uint256) public pure override returns (bool) {
        revert();
    }

    function allowance(address, address) public view virtual override returns (uint256) {
        revert();
    }

    function approve(address, uint256) public virtual override returns (bool) {
        revert();
    }

    function transferFrom(address, address, uint256) public virtual override returns (bool) {
        revert();
    }

    function increaseAllowance(address, uint256) public virtual override returns (bool) {
        revert();
    }

    function decreaseAllowance(address, uint256) public virtual override returns (bool) {
        revert();
    }
}
