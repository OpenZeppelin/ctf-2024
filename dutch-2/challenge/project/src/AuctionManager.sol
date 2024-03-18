// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {MerkleProofLib} from "solmate/utils/MerkleProofLib.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import {Math} from "src/util/Math.sol";

contract AuctionManager {
    using FixedPointMathLib for uint128;
    using SafeTransferLib for ERC20;

    enum States {
        Created,
        Accepting,
        Reveal,
        Void,
        Final
    }

    struct BidEncrypted {
        address sender;
        uint128 amountQuote;
        uint128 baseAmountFilled;
        uint128 baseExtracted;
        bytes32 commit;
        Math.Point publicKey;
        bytes32 encrypted;
    }

    struct Time {
        uint32 start;
        uint32 end;
        uint32 startVesting;
        uint32 endVesting;
        uint128 cliff;
    }

    struct DataAuction {
        address seller;
        uint128 baseLowest;
        uint128 quoteLowest;
        uint256 privateKey;
    }

    struct AuctionParameters {
        address tokenBase;
        address tokenQuote;
        uint256 resQuoteBase;
        uint128 totalBase;
        uint128 minBid;
        bytes32 merkle;
        Math.Point publicKey;
    }

    struct FinalData {
        uint256 resQuoteBase;
        uint128 totalBase;
        uint128 baseFilled;
        uint256 prevQuoteBase;
        uint256 prevIndex;
    }

    struct Auction {
        Time time;
        AuctionParameters parameters;
        DataAuction data;
        BidEncrypted[] bids;
    }

    uint256 public currentId;

    mapping(uint256 => Auction) public auctions;

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

    function create(AuctionParameters calldata params, Time calldata time) external returns (uint256) {
        if (time.end <= block.timestamp) revert();
        if (time.start >= time.end) revert();
        if (time.end > time.startVesting) revert();
        if (time.startVesting > time.endVesting) revert();
        if (time.cliff > 1e18) revert();
        if ((params.minBid).mulDivDown(type(uint128).max, params.totalBase) > params.resQuoteBase) revert();

        uint256 id = ++currentId;

        Auction storage a = auctions[id];
        a.parameters = params;
        a.time = time;
        a.data.quoteLowest = type(uint128).max;
        a.data.seller = msg.sender;

        uint256 beforeBalance = ERC20(params.tokenBase).balanceOf(address(this));

        ERC20(params.tokenBase).safeTransferFrom(msg.sender, address(this), params.totalBase);

        uint256 afterBalance = ERC20(params.tokenBase).balanceOf(address(this));
        if (afterBalance - beforeBalance != params.totalBase) revert();

        return id;
    }

    function addBid(
        uint256 id,
        uint128 amountQuote,
        bytes32 commit,
        Math.Point calldata publicKey,
        bytes32 encrypted,
        bytes32[] calldata proof
    ) external checkState(States.Accepting, auctions[id]) returns (uint256) {
        Auction storage auction = auctions[id];
        if (auction.parameters.merkle != bytes32(0)) {
            if (!MerkleProofLib.verify(proof, auction.parameters.merkle, keccak256(abi.encodePacked(msg.sender)))) {
                revert();
            }
        }

        if (msg.sender == auction.data.seller) revert();

        if (amountQuote < auction.parameters.minBid || amountQuote == 0 || amountQuote == type(uint128).max) revert();

        if (auction.bids.length >= 1000) revert();

        auction.bids.push(
            BidEncrypted({
                sender: msg.sender,
                amountQuote: amountQuote,
                commit: commit,
                publicKey: publicKey,
                encrypted: encrypted,
                baseAmountFilled: 0,
                baseExtracted: 0
            })
        );

        ERC20(auction.parameters.tokenQuote).safeTransferFrom(msg.sender, address(this), amountQuote);

        return auction.bids.length;
    }

    function show(uint256 id, uint256 privateKey, bytes calldata data)
        external
        checkState(States.Reveal, auctions[id])
    {
        Auction storage auction = auctions[id];
        if (auction.data.seller != msg.sender) revert();

        Math.Point memory publicKey = Math.publicKey(privateKey);
        if (
            publicKey.x != auction.parameters.publicKey.x || publicKey.y != auction.parameters.publicKey.y
                || (publicKey.x == 1 && publicKey.y == 1)
        ) revert();

        auction.data.privateKey = privateKey;

        if (0 != data.length) {
            (uint256[] memory indices, uint128 base, uint128 quote) = abi.decode(data, (uint256[], uint128, uint128));
            finalize(id, indices, base, quote);
        }
    }

    function finalize(uint256 id, uint256[] memory indices, uint128 base, uint128 quote)
        public
        checkState(States.Reveal, auctions[id])
    {
        Auction storage auction = auctions[id];
        uint256 sellerPrivateKey = auction.data.privateKey;
        if (sellerPrivateKey == 0) revert();

        if (indices.length != auction.bids.length) revert();

        FinalData memory data = FinalData({
            resQuoteBase: auction.parameters.resQuoteBase,
            totalBase: auction.parameters.totalBase,
            baseFilled: 0,
            prevQuoteBase: type(uint256).max,
            prevIndex: 0
        });

        auction.data.baseLowest = base;
        auction.data.quoteLowest = quote;

        uint256[] memory bidSeen = new uint256[]((indices.length / 256) + 1);

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

        for (uint256 i; i < bidSeen.length - 1; i++) {
            if (bidSeen[i] != type(uint256).max) revert();
        }

        if (((1 << (indices.length % 256)) - 1) != bidSeen[bidSeen.length - 1]) revert();

        if (data.baseFilled > data.totalBase) {
            revert();
        }

        if (data.totalBase != data.baseFilled) {
            auction.parameters.totalBase = data.baseFilled;
            ERC20(auction.parameters.tokenBase).safeTransfer(auction.data.seller, data.totalBase - data.baseFilled);
        }

        ERC20(auction.parameters.tokenQuote).safeTransfer(auction.data.seller, quote.mulDivDown(data.baseFilled, base));
    }

    function refund(uint256 id, uint256 index) external checkState(States.Final, auctions[id]) {
        Auction storage auction = auctions[id];
        BidEncrypted storage bid = auction.bids[index];
        if (msg.sender != bid.sender) {
            revert();
        }

        if (bid.baseAmountFilled != 0) {
            revert();
        }

        bid.sender = address(0);

        ERC20(auction.parameters.tokenQuote).safeTransfer(msg.sender, bid.amountQuote);
    }

    function withdraw(uint256 id, uint256 index) external checkState(States.Final, auctions[id]) {
        Auction storage auction = auctions[id];
        BidEncrypted storage bid = auction.bids[index];
        if (msg.sender != bid.sender) revert();

        uint128 amountBase = bid.baseAmountFilled;
        if (0 == amountBase) revert();

        uint128 baseAvailable = tokensAvailableForWithdrawal(id, amountBase);

        baseAvailable = baseAvailable - bid.baseExtracted;
        bid.baseExtracted += baseAvailable;

        if (bid.amountQuote != 0) {
            uint256 quoteBought = amountBase.mulDivDown(auction.data.quoteLowest, auction.data.baseLowest);
            bid.amountQuote = 0;

            ERC20(auction.parameters.tokenQuote).safeTransfer(msg.sender, bid.amountQuote - quoteBought);
        }

        ERC20(auction.parameters.tokenBase).safeTransfer(msg.sender, baseAvailable);
    }

    function auctionCancel(uint256 id) external {
        Auction storage auction = auctions[id];

        if (auction.data.seller != msg.sender) revert();
        if (type(uint128).max != auction.data.quoteLowest) revert();

        auction.data.seller = address(0);
        auction.time.end = type(uint32).max;

        ERC20(auction.parameters.tokenBase).safeTransfer(msg.sender, auction.parameters.totalBase);
    }

    function bidCancel(uint256 id, uint256 index) external {
        Auction storage auction = auctions[id];
        BidEncrypted storage bid = auction.bids[index];

        if (msg.sender != bid.sender) revert();
        if (block.timestamp >= auction.time.end) {
            if (block.timestamp <= auction.time.end + 24 hours || auction.data.quoteLowest != type(uint128).max) {
                revert();
            }
        }

        bid.commit = 0;
        bid.sender = address(0);

        ERC20(auction.parameters.tokenQuote).safeTransfer(msg.sender, bid.amountQuote);
    }

    function tokensAvailableForWithdrawal(uint256 id, uint128 amountBase)
        public
        view
        returns (uint128 tokensAvailable)
    {
        Auction memory auction = auctions[id];
        return Math.availableTokensAtTime(
            auction.time.startVesting, auction.time.endVesting, uint32(block.timestamp), auction.time.cliff, amountBase
        );
    }

    function genCommitment(bytes32 message) public pure returns (bytes32) {
        return keccak256(abi.encode(message));
    }

    function genMessage(uint128 amountBase, bytes16 nonce) external pure returns (bytes32) {
        return bytes32(abi.encodePacked(amountBase, nonce));
    }
}
