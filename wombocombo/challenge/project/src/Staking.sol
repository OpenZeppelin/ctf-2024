// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Token} from "src/Token.sol";
import {ERC2771Context} from "openzeppelin/metatx/ERC2771Context.sol";
import {Multicall} from "openzeppelin/utils/Multicall.sol";

contract Staking is Multicall, ERC2771Context {
    Token public immutable stakingToken;
    Token public immutable rewardsToken;

    address public owner;

    uint256 public duration;
    uint256 public finishAt;
    uint256 public updatedAt;
    uint256 public rewardRate;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    uint256 public earnedTotal;

    constructor(Token _stakingToken, Token _rewardToken, address _forwarder) ERC2771Context(_forwarder) {
        owner = _msgSender();
        stakingToken = _stakingToken;
        rewardsToken = _rewardToken;
    }

    modifier onlyOwner() {
        require(_msgSender() == owner, "not authorized");
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return _min(finishAt, block.timestamp);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return rewardPerTokenStored + (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) / totalSupply;
    }

    function stake(uint256 _amount) external {
        address user = _msgSender();
        updateReward(user);
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(user, address(this), _amount);
        balanceOf[user] += _amount;
        totalSupply += _amount;
    }

    function withdraw(uint256 _amount) external {
        address user = _msgSender();
        updateReward(user);
        require(_amount > 0, "amount = 0");
        balanceOf[user] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(user, _amount);
    }

    function earned(address _account) public view returns (uint256) {
        return
            ((balanceOf[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) + rewards[_account];
    }

    function getReward() external {
        address user = _msgSender();
        updateReward(user);
        uint256 reward = rewards[user];
        earnedTotal += reward;
        if (reward > 0) {
            rewards[user] = 0;
            rewardsToken.transfer(user, reward);
        }
    }

    function setRewardsDuration(uint256 _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(uint256 _amount) external onlyOwner {
        updateReward(address(0));
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint256 remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(rewardRate * duration <= rewardsToken.balanceOf(address(this)), "reward amount > balance");

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    function updateReward(address _account) internal {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
    }
}
