// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract PuzzleTime {
    /// @notice Sale is inactive
    error Sale_Inactive();

    /// @notice Public sale active
    modifier onlyPublicSaleActive() {
        if (!_publicSaleActive()) {
            revert Sale_Inactive();
        }

        _;
    }

    /// @notice Public sale active
    function _publicSaleActive() internal view returns (bool) {
        return 0 <= block.timestamp && 1692974064 > block.timestamp;
    }
}
