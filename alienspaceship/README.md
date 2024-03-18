## Solution

Alien Spaceship is hard EVM challenge which provides teams with the bytecode of a smart contract. Per the description, teams need to take over control of their spaceship and successfully `abortMission`.

First, you can get the bytecode of the contract by using the eth_getCode RPC Method or simply copying the bytecode provided in the [deploy script](challenge/project/script/Deploy.s.sol). With this, you can use a decompiler. However, only a few decompilers work for this bytecode. [Here](https://app.dedaub.com/decompile?md5=60cad9a4c1fe82b05f6591dcceb5ecdb) is an example of using the Dedaub decompiler.

With the decompiled contract, you can trace the steps needed to call the `abortMission` function. For easy reference, we will use the [AlienSpaceship](challenge/project/src/AlienSpaceship.sol) source contract.

As we can see from the `abortMission` function, the criteria to call this function is:

- `distance()` must be less than 1_000_000 * 10**18
- `payloadMass` must be less than 1_000 * 10**18
- `numArea51Visits` must be greater than 0
- `msg.sender` must have code (i.e. be a smart contract not calling from constructor)

The `distance()` function calls the `_calculateDistance` function passing three points stored in the contract: x, y and z. The calculation function employs the L1 norm (also known as the Manhattan distance or taxicab geometry) -- for each coordinate, the function computes its absolute value using the `_abs` helper function. The purpose of using absolute values is to ensure distance is always considered as a positive quantity, regardless of the direction. Then, the distance is calculated as the sum of the absolute values of the x, y, and z coordinates, a way of measuring distance in a grid-based path.

To pass the first check, the return of the calculation must be less than 1_000_000 * 10**18. If we look for modifications to the position points, we notice that the `visitArea51` function sets the position points to high values exceeding the criteria. However, the `jumpThroughWormhole` function let's us choose the points. Therefore, we know that the `visitArea51` function must be called before the `jumpThroughWormhole` function.

Both mentioned functions require the `msg.sender` to have the `CAPTAIN` role. In order to get this, we can look at the `applyForPromotion` function which allows us to pass a role that we want to get promoted to. However, the first check requires us to already have the `PHYSICIST` role before `CAPTAIN`. To get the former role, we can use the `applyForJob` function but, similarly, this function requires us to have the `ENGINEER` role before. We can simply get the latter role by calling teh `applyForJob` function in the start.

To get the `PHYSICIST` role, the AlienSpaceship contract must hold the `ENGINEER` role as well. If we check the `runExperiment` function, we notice that there's a way we can make the contract call itself which can be used to call the `applyForJob` function like we did. 

Once the contract has the `ENGINEER` role, we can call the `applyForJob` function and claim the `PHYSICIST` role. Going back to the `applyForPromotion` function, we have another check to pass: 12 seconds must pass between our promotion to `PHYSICIST` and our call to `applyForPromotion`. Thefore, we need to separate the solve script into two transactions to pass this check.

The next check in the function verifies that we have enabled the `enabledTheWormholes` variable. To do so, we need to call the `enableWormholes` function as soon as we obtain the `PHYSICIST` role and before calling the `applyForPromotion` function. The `enableWormholes` function needs to be called by an EOA (Externally Owned Account) or under specific conditions that relate to the presence of contract code (i.e. calling in constructor). Calling in constructor also makes it easier for us to split the solve into two parts to bypass the other check mentioned before.

At this point, we should have the `CAPTAIN` role allowing us to call the `visitArea51` and `jumpThroughWormhole` functions. The `visitArea51` function takes a `secret` parameter, which must be 51 - the address of the caller in uint160 format (allowing this calculation to overflow). This function will increment our number of visits to Area 51, passing one of the remaining cheks in the `abortMission` function. Aditionally, it will increase our position numbers, so we need to call the `jumpThroughWormhole` function to set them to the desired values that pass the check. 

This function requires one of the last checks to pass: that the payload mass of the ship is less than 1_000 * 10 ** 18. To do so, we need to call the `dumpPayload` function some time before passing the right amount. Now we can call the `jumpThroughWormhole` function passing values that pass the distance check in the `abortMission` function.

Now, we can call the `abortMission` function and get the flag!