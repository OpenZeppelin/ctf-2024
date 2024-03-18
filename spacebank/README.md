## Solution

In solving this challenge, the primary objective is to trigger the `explodeSpaceBank` function, as outlined in the [Challenge](challenge/project/src/Challenge.sol) contract. This task requires navigating through a series of checks, each serving as a step toward achieving the goal of "exploding" the bank.

First, we need to understand the prerequisites of invoking the `explodeSpaceBank` function. Key among these is ensuring that the call occurs exactly two blocks after the `alarmTime` has been set. Additionally, the address stored in `_createdAddress` must be devoid of code, signifying either an externally owned account (EOA) or a contract that has been self-destructed at the point of verification. Moreover, the `SpaceBank` contract must be entirely empty of funds.

```solidity
///Make the bank explode
function explodeSpaceBank() external {
    require(block.number == alarmTime + 2, "Can't explode the bank");
    uint256 codeSize;
    address value = _createdAddress;
    assembly {
        codeSize := extcodesize(value)
    }
    require(codeSize == 0, "You were caught");
    require(token.balanceOf(address(this)) == 0, "The bank still has funds");
    exploded = true;
}
```

To set the `alarmTime`, we indirectly engage the `_emergencyAlarmProtocol` by triggering the second alarm. This protocol is invoked via the `_emergencyAlarms` modifier, applied to the `deposit` function. Notably, the entered variable must be true for `_emergencyAlarmProtocol` to be called, a condition we satisfy by initiating a flash loan via the `flashLoan` function. This action sets the stage for a contract implementing the `executeFlashLoan` function that deposits into the `SpaceBank`, thereby escalating the alarm levels.

```solidity
if (EmergencyAlarms == 2) {
    //second alarm
    bytes32 MagicNumber = bytes32(block.number);
    uint256 balance = address(this).balance;
    address newContractAddress;
    assembly {
        newContractAddress := create2(0, add(data, 0x20), mload(data), MagicNumber)
    }
    require(address(this).balance > balance, "You need to send ether to pass through security");
    _createdAddress = newContractAddress;
    alarmTime = block.number;
}
```

```solidity
function flashLoan(uint256 amount, address flashLoanReceiver) external {
    uint256 initialBalance = token.balanceOf(address(this));

    require(initialBalance >= amount, "Not enough liquidity");
    // Transfer loan amount to the receiver
    require(token.transfer(flashLoanReceiver, amount), "Transfer failed");

    // Execute custom logic in the receiver's contract
    entered = true;

    (bool success, bytes memory result) =
        flashLoanReceiver.call(abi.encodeWithSignature("executeFlashLoan(uint256)", amount));
    if (success == false) revert(string(result));
    entered = false;
    uint256 fee = amount / 1000; // 0.1% fee
    uint256 currentBalance = token.balanceOf(address(this));
    require(currentBalance >= initialBalance + fee, "Loan not repaid with fee");
}
```

For the first alarm, we need to provide data that, when decoded into a `uint256`, matches the remainder of `block.number % 47`. The second alarm will create a contract using `CREATE2` and check that it has funds. To pass this, we need to pre-calculate this contract address and send it an amount of Ether that is greater than the current balance of the `SpaceBank` contract. Additionally, we are able to define the code of this contract that gets created. Therefore, we have the possibility of self-destructing or doing any other operation.

Going back to the `explodeSpaceBank` function, we pass the first check, but now face the second and third checks. Specifically, the second check verifies that the `CREATE2`-created contract has no code (i.e. has self-destructed). Then, the third check verifies that the `SpaceBank` doesn't hold any tokens. This is achieved by executing a flash loan for the total amount of tokens available, followed by a withdrawal of these tokens, leaving the bank's coffers empty

By implementing these steps, we can successfully destroy the bank and solve the challenge. You can check the solve script [here](challenge/project/script/Solve.s.sol).