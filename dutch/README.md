## Solution

This challenge predominantly utilizes Vyper version 0.4.0b4, which introduces the capability to import modules. In this case, it uses `snekmate` for the ERC721 standard implementation. To secure the flag, one must successfully remove the `Art` NFT from the `Auction` contract by winning the auction. The challenge, however, is the lack of tokens to place a winning bid.

Upon examining the [deploy script](challenge/project/script/Deploy.s.sol), it's evident that the deploying address mints 1 WETH for itself and authorizes the `Auction` contract to use it. The `Auction` contract's `buyWithPermit` function, intended to allow bids through the `permit` mechanism, mistakenly allows any recipient to be specified for receiving the `Art` upon winning. Additionally, since the WETH contract lacks a `permit` function, attempts to use this function default to the fallback function. This results in the deposit of 0 Ether, inadvertently bypassing the expected functionality.

Leveraging the 1 WETH minted earlier, it's possible to bid and win the auction on behalf of the user, ultimately acquiring the Art NFT and completing the challenge!

A similar scenario occured in production before: if you want more information, check out [this](https://medium.com/zengo/without-permit-multichains-exploit-explained-8417e8c1639b) exploit post-mortem.