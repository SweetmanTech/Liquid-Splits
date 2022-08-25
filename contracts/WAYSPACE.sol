// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./PuzzleDrop.sol";
import "./AlbumMetadata.sol";

contract WAYSPACE is PuzzleDrop, AlbumMetadata {
    constructor(string[] memory _musicMetadata)
        PuzzleDrop("WAYSPACE", "JACKIE")
    {
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
