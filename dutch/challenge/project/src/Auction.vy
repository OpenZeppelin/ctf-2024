# pragma version ^0.4.0b4

from ethereum.ercs import IERC721

interface IERC20Permit:
    def permit(owner: address, spender: address, amount: uint256, deadline: uint256, v: uint8, r: bytes32, s: bytes32): nonpayable
    def transferFrom(receiver: address, to: address, amount: uint256): nonpayable
    def transfer(to: address, amount: uint256): nonpayable

DURATION: constant(uint256) = 604800

token: public(IERC20Permit)
nft: public(IERC721)
nftId: public(uint256)

seller: public(address)
startingPrice: public(uint256)
startAt: public(uint256)
expiresAt: public(uint256)
discountRate: public(uint256)

IERC721_TOKENRECEIVER_SELECTOR: public(constant(bytes4)) = 0x150B7A02

@deploy
def __init__(_startingPrice: uint256, _discountRate: uint256, _nft: IERC721, _nftId: uint256, _token: IERC20Permit):
    self.seller = msg.sender
    self.startingPrice = _startingPrice
    self.startAt = block.timestamp
    self.expiresAt = block.timestamp + DURATION
    self.discountRate = _discountRate

    assert _startingPrice >= _discountRate * DURATION, "starting price < min"

    self.nft = _nft
    self.nftId = _nftId
    self.token = _token


@internal
@view
def _get_price() -> uint256:
    return self.startingPrice - (self.discountRate * (block.timestamp - self.startAt))

@external
@view
def getPrice() -> uint256:
    return self._get_price()


@external
def buyWithPermit(
    buyer: address,
    receiver: address,
    amount: uint256,
    deadline: uint256,
    v: uint8,
    r: bytes32,
    s: bytes32
):
    extcall self.token.permit(buyer, self, amount, deadline, v, r, s)

    self.auction(buyer, receiver)

@external
def buy():
    self.auction(msg.sender, msg.sender)

@internal
def auction(buyer: address, receiver: address):
    assert block.timestamp < self.expiresAt, "auction expired"

    price: uint256 = self._get_price()

    extcall self.token.transferFrom(buyer, self, price)
    extcall self.nft.transferFrom(self, receiver, self.nftId)
    extcall self.token.transfer(self.seller, price)

@external
def onERC721Received(operator: address, owner: address, token_id: uint256, data: Bytes[1_024]) -> bytes4:
    return IERC721_TOKENRECEIVER_SELECTOR