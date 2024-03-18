# pragma version ^0.4.0b4

from snekmate.tokens import ERC721 as base_nft

implements: base_nft.IERC721
initializes: base_nft

exports: (
    base_nft.safe_mint,
    base_nft.transferFrom,
    base_nft.approve,
    base_nft.totalSupply,
    base_nft.balanceOf,
    base_nft.ownerOf,
    base_nft.getApproved,
    base_nft.isApprovedForAll,
    base_nft.setApprovalForAll,
    base_nft.supportsInterface,
    base_nft.safeTransferFrom
)

@deploy
def __init__(minter: address):
    base_nft.__init__("Art", "ART", "https://ctf.openzeppelin.com", "Art", "1")
    base_nft.is_minter[minter] = True
