## Solution

Dutch 2 introduces a more intricate auction system than Dutch 1, incorporating state transitions, sealed bids, and additional complexities. As outlined in the [Challenge contract](challenge/project/src/Challenge.sol), our objective is to drain the quote token balance from the AuctionManager contract.

Central to the bid and auction logic, the `checkState()` modifier checks the current state of an auction based on the block timestamp and the values of certain variables. The possible states are: 

1. `Created`: The auction has been created but hasn't started yet.
2. `Accepting`: The auction is currently accepting bids from participants.
3. `Final`: The auction has ended, and the final price has been determined.
4. `Reveal`: A 24-hour period after the auction ends, during which participants can reveal their bids.
5. `Void`: The auction is considered void if it hasn't been finalized within 24 hours after the end time.

```solidity
modifier checkState(States state, Auction storage auction) {
    if (block.timestamp < auction.time.start) {
        if (state != States.Created) revert();
    } else if (block.timestamp < auction.time.end) {
        if (state != States.Accepting) revert();
    } else if (auction.data.quoteLowest != type(uint128).max) {
        if (state != States.Final) revert();
    } else if (block.timestamp <= auction.time.end + 24 hours) {
        if (state != States.Reveal) revert();
    } else if (block.timestamp > auction.time.end + 24 hours) {
        if (state != States.Void) revert();
    } else {
        revert();
    }
    _;
}
```

Each state permits specific actions while restricting others. However, the critical observation here is that the `finalize()` function, which moves the auction to the `Final` state, allows setting `quoteLowest` to an attacker-controlled value. If this value is set to `type(uint128).max`, it effectively reopens the door for actions like `auctionCancel()` and `bidCancel()`, which should be locked out at this stage. This is possible if the current block timestamp is greater than the `end` of the auction, making the value of `quoteLowest` be used to determine if the `finalize()` function can been called.

To successfully exploit the vulnerability, we must carefully choose the values of `minBid` and `resQuoteBase` to satisfy all the inequality requirements in the `create()`, `addBid()`, and `finalize()` functions.

```solidity
        for (uint256 i; i < indices.length; i++) {
            uint256 index = indices[i];
            BidEncrypted storage bid = auction.bids[index];

            uint256 mapIndex = index / 256;
            uint256 bitMap = bidSeen[mapIndex];
            uint256 bitIndex = 1 << (index % 256);
            if (bitIndex == 1 & bitMap) revert();
            bidSeen[mapIndex] = bitMap | bitIndex;

            Math.Point memory commonPoint = Math.mul(sellerPrivateKey, bid.publicKey);
            if (commonPoint.y == 1 && commonPoint.x == 1) continue;

            bytes32 decrypted = Math.decrypt(commonPoint, bid.encrypted);
            if (genCommitment(decrypted) != bid.commit) continue;

            uint128 amountBase = uint128(uint256(decrypted >> 128));

            uint256 quotePerBase = bid.amountQuote.mulDivDown(type(uint128).max, amountBase);
            if (quotePerBase >= data.prevQuoteBase) {
                if (quotePerBase == data.prevQuoteBase) {
                    if (data.prevIndex > index) revert();
                } else {
                    revert();
                }
            }

            if (quotePerBase < data.resQuoteBase) continue;

            if (data.totalBase == data.baseFilled) continue;

            data.prevIndex = index;
            data.prevQuoteBase = quotePerBase;

            if (amountBase + data.baseFilled > data.totalBase) {
                amountBase = data.totalBase - data.baseFilled;
            }

            data.baseFilled += amountBase;
            bid.baseAmountFilled = amountBase;
        }

        if (quote.mulDivDown(type(uint128).max, base) != data.prevQuoteBase) revert();
```

Since `quote` must equal `type(uint128).max`, we can form the following equation:

```
(2**128-1) * (2**128-1) / base = quote * (2**128-1) / baseAmount
```

So, we need to set `base` to `(2**128-1)` and `quote` equal to `baseAmount`. Additionally, there are constraints on `resQuoteBase` and `amountQuote` in relation to `minBid` and `totalBase`:

```
minBid / totalBase < resQuoteBase <= (2**128-1) / base
amountQuote > minBid
```

To perform the exploit, we need to separate the buyer and seller in two different contracts acting together for the following steps:

1. Initiating the Auction: Seller contract initiates the auction with no vesting period and a deliberately short duration, contributing a predefined amount of base tokens.
2. Bidding on the Auction: Buyer contract places a bid with a base-to-quote token ratio of 1:1, ensuring the bid amount is strategically less than the total base tokens available.
3. Manipulating Finalization: Post-auction, Seller contract invokes the `finalize()` function, setting both `quoteLowest` and `baseLowest` to their maximum possible values. This transfers the unsold base tokens and matched quote tokens back.
4. Executing the Cancelation: By then invoking `auctionCancel()`, we retrieve any remaining base tokens, effectively resetting the positions without loss. Simultaneously, `bidCancel()` allows the recovery of the bid's quote tokens, completing the cycle which can be repeated to completely drain the auction contract, or can be executed in a single iteration with the right parameters.

Once the `AuctionManager` contract is drained, we can get the flag!