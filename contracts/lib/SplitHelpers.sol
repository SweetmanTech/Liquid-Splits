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
    /// @notice constant to scale uints into percentages (1e6 == 100%)
    uint32 public constant PERCENTAGE_SCALE = 1e6;

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
        _holders = _sortAddresses(_holders);
        return _uniqueAddresses(_holders);
    }

    /// @notice Returns array of percent allocations for current liquid split.
    /// @dev sortedAccounts _must_ be sorted for this to work properly
    /// @dev sortedAccounts _must_ be unique for this to work properly
    function getPercentAllocations(address[] memory sortedAccounts)
        public
        pure
        returns (uint32[] memory percentAllocations)
    {
        uint32 numUniqRecipients = uint32(sortedAccounts.length);

        uint32[] memory _percentAllocations = new uint32[](numUniqRecipients);
        for (uint256 i = 0; i < numUniqRecipients; ) {
            _percentAllocations[i] += uint32(
                PERCENTAGE_SCALE / numUniqRecipients
            );
            unchecked {
                ++i;
            }
        }
        _percentAllocations[0] +=
            PERCENTAGE_SCALE -
            uint32(PERCENTAGE_SCALE / numUniqRecipients) *
            numUniqRecipients;
        return _percentAllocations;
    }
}
