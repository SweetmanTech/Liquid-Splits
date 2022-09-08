// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/ISplitMain.sol";
import "./PureHelpers.sol";

contract SplitHelpers is PureHelpers {
    /// @notice 0xSplits address for split.
    address payable public immutable payoutSplit;
    /// @notice 0xSplits address for updating & distributing split.
    ISplitMain public splitMain;
    /// @notice address of ERC721 contract with controlling tokens.
    IERC721 public nftContract;
    /// @notice array of token holders as split recipients.
    uint32[] public tokenIds;
    /// @notice Funds have been received. activate liquidity.
    event FundsReceived(address indexed source, uint256 amount);

    constructor(address _nftContractAddress, uint32[] memory _tokenIds) {
        /// Establish NFT holder contract
        nftContract = IERC721(_nftContractAddress);
        /// Establish tokenIds from NFT contract for split recipients.
        tokenIds = _tokenIds;
        /// Establish interface to splits contract
        splitMain = ISplitMain(0x2ed6c4B5dA6378c7897AC67Ba9e43102Feb694EE);
        // create dummy mutable split with this contract as controller;
        // recipients & distributorFee will be updated on first payout
        address[] memory recipients = new address[](2);
        recipients[0] = address(0);
        recipients[1] = address(1);
        uint32[] memory percentAllocations = new uint32[](2);
        percentAllocations[0] = uint32(500000);
        percentAllocations[1] = uint32(500000);
        payoutSplit = payable(
            splitMain.createSplit(
                recipients,
                percentAllocations,
                0,
                address(this)
            )
        );
    }

    /// @notice Returns array of sorted accounts for current liquid split.
    function getHolders() public view returns (address[] memory) {
        address[] memory _holders = new address[](tokenIds.length);
        uint256 loopLength = _holders.length;
        for (uint256 i = 0; i < loopLength; ) {
            _holders[i] = nftContract.ownerOf(tokenIds[i]);
            unchecked {
                ++i;
            }
        }
        return _sortAddresses(_holders);
    }

    /// @notice Returns array of percent allocations for current liquid split.
    /// @dev sortedAccounts _must_ be sorted for this to work properly
    function getPercentAllocations(address[] memory sortedAccounts)
        public
        pure
        returns (uint32[] memory percentAllocations)
    {
        uint32 numRecipients = uint32(sortedAccounts.length);
        uint32 numUniqRecipients = _countUniqueRecipients(sortedAccounts);

        uint32[] memory _percentAllocations = new uint32[](numUniqRecipients);
        for (uint256 i = 0; i < numUniqRecipients; ) {
            _percentAllocations[i] += uint32(1e6 / numRecipients);
            unchecked {
                ++i;
            }
        }
        // TODO: replace 1e6 w PERCENTAGE_SCALE or some similarly named constant in contract
        _percentAllocations[0] +=
            1e6 -
            uint32(1e6 / numRecipients) *
            numRecipients;
        return _percentAllocations;
    }
}
