// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./lib/SplitHelpers.sol";

contract LiquidSplit is SplitHelpers {
    constructor(address _nftContractAddress, uint32[] memory _tokenIds)
        SplitHelpers(_nftContractAddress, _tokenIds)
    {}

    /// @notice This allows this contract to receive native currency funds from other contracts
    /// Uses event logging for UI reasons.
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
        withdraw();
    }

    /// @notice distributes ETH to Liquid Split NFT holders
    function withdraw() public {
        updateHolders();
        address[] memory unsorted = getHolders();
        address[] memory accounts = sortAddresses(unsorted);
        uint32[] memory percentAllocations = getPercentAllocations(accounts);
        // atomically deposit funds into split, update recipients to reflect current supercharged NFT holders,
        // and distribute
        payoutSplit.transfer(address(this).balance);
        splitMain.updateAndDistributeETH(
            payoutSplit,
            accounts,
            percentAllocations,
            0,
            address(0)
        );
    }
}
