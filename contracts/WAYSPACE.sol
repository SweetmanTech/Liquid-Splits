// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./PuzzleDrop.sol";
import "./AlbumMetadata.sol";

contract WAYSPACE is AlbumMetadata, PuzzleDrop {
    constructor(string[] memory _musicMetadata)
        PuzzleDrop("WAYSPACE", "JACKIE")
    {
        setupAlbumMetadata(_musicMetadata);
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function purchase(uint256 _quantity, uint8 _songId)
        external
        payable
        onlyPublicSaleActive
        onlyValidPrice(singlePrice, _quantity)
        returns (uint256)
    {
        uint256 firstMintedTokenId = _purchase(_quantity, _songId);
        return firstMintedTokenId;
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function purchaseBundle(uint256 _quantity)
        external
        payable
        onlyPublicSaleActive
        onlyValidPrice(bundlePrice, _quantity)
        returns (uint256)
    {
        uint8 songIdOne = 1;
        uint8 songIdTwo = 2;
        _purchase(_quantity, songIdOne);
        uint256 firstMintedTokenId = _purchase(_quantity, songIdTwo);
        return firstMintedTokenId;
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function _purchase(uint256 quantity, uint8 _songId)
        internal
        onlyValidSongId(_songId)
        returns (uint256)
    {
        _mint(msg.sender, quantity);
        _setSongURI(_nextTokenId(), quantity, _songId);
        uint256 lastMintedTokenId = _nextTokenId() - 1;
        uint256 firstMintedTokenId = lastMintedTokenId - quantity;

        emit Sale({
            to: msg.sender,
            quantity: quantity,
            pricePerToken: bundlePrice,
            firstPurchasedTokenId: firstMintedTokenId
        });
        return firstMintedTokenId;
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

        uint8 songId = songIds[tokenId];
        return songURI(songId);
    }
}
