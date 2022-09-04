// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./lib/PuzzleDrop.sol";
import "./lib/AlbumMetadata.sol";

contract MERGE is AlbumMetadata, PuzzleDrop {
    uint256 immutable MERGE_TTD = 58750000000000000000000;

    constructor(string[] memory _musicMetadata) PuzzleDrop("The Merge", "SAD") {
        setupAlbumMetadata(_musicMetadata);
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function purchase(uint256 _quantity)
        external
        payable
        onlyPublicSaleActive
        onlyValidPrice(singlePrice, _quantity)
        returns (uint256)
    {
        uint256 firstMintedTokenId = _purchase(_quantity, 1);
        return firstMintedTokenId;
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function _purchase(uint256 quantity, uint8 _songId)
        internal
        onlyValidSongId(_songId)
        returns (uint256)
    {
        uint256 start = _nextTokenId();
        _mint(msg.sender, quantity);
        _setSongURI(start, quantity, _songId);

        emit Sale({
            to: msg.sender,
            quantity: quantity,
            pricePerToken: bundlePrice,
            firstPurchasedTokenId: start
        });
        return start;
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
        uint8 songId = currentSong();
        return songURI(songId);
    }

    /// @notice Returns current song URI based on TheMergeTTD.
    function currentSong() public view returns (uint8) {
        return uint8(block.timestamp % songCount) + 1;
    }

    /// @notice Returns if the merge has occured.
    function isMerged() public view returns (bool) {
        return block.difficulty > MERGE_TTD;
    }

    /// @notice Current price. Changes once the merge happens.
    function price() public view returns (uint256) {
        if (!isMerged()) {
            return MERGE_TTD / 1000000;
        } else {
            return 100000000000000000; //TODO: develop mechanism to set post-merge price
        }
    }
}
