// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/ISplitMain.sol";

contract SplitHelpers {
    /// @notice 0xSplits address for split.
    address payable public immutable payoutSplit;
    /// @notice 0xSplits address for updating & distributing split.
    ISplitMain public splitMain;
    /// @notice address of ERC721 contract with controlling tokens.
    IERC721 public nftContract;
    /// @notice array of token holders as split recipients.
    uint32[] public tokenIds;
    /// @notice array of token holders;
    address[] public holders;
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

    /// @notice Returns array of accounts for current liquid split.
    function getHolders() public view returns (address[] memory) {
        return holders;
    }

    /// @notice Returns array of accounts for current liquid split.
    function updateHolders() public {
        holders = [nftContract.ownerOf(tokenIds[0])];
        for (uint256 i = 1; i < tokenIds.length; ) {
            address holder = nftContract.ownerOf(tokenIds[i]);
            holders.push(holder);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Returns sorted array of accounts for 0xSplits.
    function sortAddresses(address[] memory addresses)
        public
        pure
        returns (address[] memory)
    {
        for (uint256 i = addresses.length - 1; i > 0; i--)
            for (uint256 j = 0; j < i; j++)
                if (addresses[i] < addresses[j])
                    (addresses[i], addresses[j]) = (addresses[j], addresses[i]);

        return addresses;
    }

    /// @notice Returns array of percent allocations for current liquid split.
    function getPercentAllocations(address[] memory accounts)
        public
        pure
        returns (uint32[] memory)
    {
        uint32 numRecipients = uint32(accounts.length);
        uint32[] memory percentAllocations = new uint32[](numRecipients);
        for (uint256 i = 0; i < numRecipients; ) {
            percentAllocations[i] = uint32(1e6 / numRecipients);
            unchecked {
                ++i;
            }
        }
        return percentAllocations;
    }
}
