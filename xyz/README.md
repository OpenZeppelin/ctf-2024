## Solution

XYZ is based on a stablecoin that is supported by lenders, borrowers, and liquidators. Per the [Challenge](challenge/project/src/Challenge.sol) contract, in order to solve the challenge the XYZ balance of the 0xCAFEBABE address must be equal to 250_000_000 * 10**18. Therefore, it's evident that we need to find a way of minting a lot of tokens.

As with all on-chain protocols, math precision is crucial. We can start by checking how minting works—the entrypoint is the `manage` function in the `Manager` contract, which updates the debt and collateral depending on the action. If the debt is updated with an increase, debt and XYZ are minted. If it's updated without an increase, debt and XYZ are burned. Collateral works similarly but with collateral and underlying tokens.

Diving into the `ERC20Signal` contract, we notice that the `mint` function uses the `divUp` operation to mint tokens. This is susceptible if we are able to manipulate and inflate the `signal` variable by a lot, making the division be almost 0, but it ends up being rounded up to 1. Therefore, this leads to precision loss where we can increase our position over many iterations of this.

```solidity
function mint(address to, uint256 amount) external onlyManager {
    _mint(to, amount.divUp(signal));
}
```

So, we identified the essential part of the challenge. Now, we can focus on preparing the scenario.

As we have 6500 sETH, we are able to donate a chunk of it and liquididate our position to inflate the signal variable. Now, we can loop as many times needed to a lot of XYZsETH-c, which can then be reedemed for XYZ. Essentially, we increase our position by 1 wei of sETH each time, resulting in the minting of 1 share of XYZsETH-c. In reality, due to the inflated signal, we should receive something like 0.00000000000000001 wei of XYZsETH-c.

After exploiting this, we should have a huge amount of XYZsETH-c which we can redeem for XYZ to receive at least 250_000_000 * 10**18 of it. With this balance, we can transfer to the 0xCAFEBABE address and solve the challenge to get the flag!