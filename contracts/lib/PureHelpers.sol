// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/ISplitMain.sol";

contract PureHelpers {
    /// @notice Returns sorted array of accounts for 0xSplits.
    function _sortAddresses(address[] memory addresses)
        internal
        pure
        returns (address[] memory)
    {
        for (uint256 i = addresses.length - 1; i > 0; i--)
            for (uint256 j = 0; j < i; j++)
                if (addresses[i] < addresses[j])
                    (addresses[i], addresses[j]) = (addresses[j], addresses[i]);

        return addresses;
    }

    /// @notice Returns number of unique recipients.
    /// @dev sortedAccounts _must_ be sorted for this to work properly
    function _countUniqueRecipients(address[] memory sortedAccounts)
        internal
        pure
        returns (uint32)
    {
        uint32 numRecipients = uint32(sortedAccounts.length);
        uint32 numUniqRecipients = 1;
        address lastRecipient = sortedAccounts[0];
        for (uint256 i = 1; i < numRecipients; ) {
            if (sortedAccounts[i] != lastRecipient) {
                unchecked {
                    ++numUniqRecipients;
                    lastRecipient = sortedAccounts[i];
                }
            }
            unchecked {
                ++i;
            }
        }

        return numUniqRecipients;
    }
}
