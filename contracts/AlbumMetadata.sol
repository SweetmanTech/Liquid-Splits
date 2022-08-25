// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract AlbumMetadata {
    mapping(uint256 => string) internal albumUri;

    /// @notice Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    function songURI(uint256 songId) public view returns (string memory) {
        return albumUri[songId];
    }

    /// @notice setup metadata for each song in WAYSPACE
    function setupAlbumMetadata(string[] memory _musicMetadata) internal {
        unchecked {
            for (uint256 i = 1; i <= _musicMetadata.length; i++) {
                albumUri[i] = _musicMetadata[i - 1];
            }
        }
    }
}
