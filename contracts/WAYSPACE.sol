// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "erc721a/contracts/ERC721A.sol";
import "./PuzzleTime.sol";
import "./AlbumMetadata.sol";

contract WAYSPACE is ERC721A, PuzzleTime, AlbumMetadata {
    /// @notice Price for Single
    uint256 public singlePrice = 22200000000000000;
    /// @notice Price for Single
    uint256 public bundlePrice = 33300000000000000;

    /// @notice Wrong price for purchase
    error Purchase_WrongPrice(uint256 correctPrice);

    constructor(string[] memory _musicMetadata) ERC721A("WAYSPACE", "JACKIE") {
        setupAlbumMetadata(_musicMetadata);
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function purchase(uint256 quantity)
        external
        payable
        onlyPublicSaleActive
        returns (uint256)
    {
        if (msg.value != singlePrice * quantity) {
            revert Purchase_WrongPrice(singlePrice * quantity);
        }

        _mint(msg.sender, quantity);
        // uint256 firstMintedTokenId = _lastMintedTokenId() - quantity;

        // emit IERC721Drop.Sale({
        //     to: _msgSender(),
        //     quantity: quantity,
        //     pricePerToken: salePrice,
        //     firstPurchasedTokenId: firstMintedTokenId
        // });
        // return firstMintedTokenId;
        return 1;
    }

    /// @notice Returns the starting token ID.
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    /// @notice Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        return songURI(tokenId);
    }
}
