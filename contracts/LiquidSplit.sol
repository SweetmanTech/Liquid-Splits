// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interfaces/ISplitMain.sol";

contract LiquidSplit {
    /// @notice 0xSplits address for split.
    address payable public immutable payoutSplit;
    /// @notice 0xSplits address for updating & distributing split.
    ISplitMain public splitMain;
    address[] public tempAccounts;
    /// @notice Funds have been received. activate liquidity.
    event FundsReceived(address indexed source, uint256 amount);

    constructor() {
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

        tempAccounts = [
            0x73C1106Ac50eEFF8B69040c95C665e674b850BC3,
            0xcfBf34d385EA2d5Eb947063b67eA226dcDA3DC38,
            0xeCF12d2259a30B156Da670031D7a836626C3a89F,
            0xE5d9ff6303c4d64E00750F5699E56c3520b0df21
        ];
    }

    //                       ,-.                  ,-.                      ,-.
    //                       `-'                  `-'                      `-'
    //                       /|\                  /|\                      /|\
    //                        |                    |                        |                      ,----------.
    //                       / \                  / \                      / \                     |ERC721Drop|
    //                     Caller            payoutSplit            FundsRecipient                `----+-----'
    //                       |                    |           withdraw()   |                            |
    //                       | ------------------------------------------------------------------------->
    //                       |                    |                        |                            |
    //                       |                    |                        |                            |
    //          ________________________________________________________________________________________________________
    //          ! ALT  /  caller is not admin or manager?                  |                            |               !
    //          !_____/      |                    |                        |                            |               !
    //          !            |                    revert Access_WithdrawNotAllowed()                    |               !
    //          !            | <-------------------------------------------------------------------------               !
    //          !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!
    //          !~[noop]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!
    //                       |                    |                        |                            |
    //                       |                    |                   send fee amount                   |
    //                       |                    | <----------------------------------------------------
    //                       |                    |                        |                            |
    //                       |                    |                        |                            |
    //                       |                    |                        |             ____________________________________________________________
    //                       |                    |                        |             ! ALT  /  send unsuccesful?                                 !
    //                       |                    |                        |             !_____/        |                                            !
    //                       |                    |                        |             !              |----.                                       !
    //                       |                    |                        |             !              |    | revert Withdraw_FundsSendFailure()    !
    //                       |                    |                        |             !              |<---'                                       !
    //                       |                    |                        |             !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!
    //                       |                    |                        |             !~[noop]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!
    //                       |                    |                        |                            |
    //                       |                    |                        | send remaining funds amount|
    //                       |                    |                        | <---------------------------
    //                       |                    |                        |                            |
    //                       |                    |                        |                            |
    //                       |                    |                        |             ____________________________________________________________
    //                       |                    |                        |             ! ALT  /  send unsuccesful?                                 !
    //                       |                    |                        |             !_____/        |                                            !
    //                       |                    |                        |             !              |----.                                       !
    //                       |                    |                        |             !              |    | revert Withdraw_FundsSendFailure()    !
    //                       |                    |                        |             !              |<---'                                       !
    //                       |                    |                        |             !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!
    //                       |                    |                        |             !~[noop]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!
    //                     Caller            payoutSplit            FundsRecipient                ,----+-----.
    //                       ,-.                  ,-.                      ,-.                     |ERC721Drop|
    //                       `-'                  `-'                      `-'                     `----------'
    //                       /|\                  /|\                      /|\
    //                        |                    |                        |
    //                       / \                  / \                      / \
    /// @notice distributes ETH to Liquid Split NFT holders
    function withdraw() public {
        address[] memory unsorted = getAccounts();
        address[] memory accounts = sortAddresses(unsorted);
        uint32 numRecipients = uint32(accounts.length);
        uint32[] memory percentAllocations = new uint32[](numRecipients);
        for (uint256 i = 0; i < numRecipients; ) {
            percentAllocations[i] = 1e6 / numRecipients;
            unchecked {
                ++i;
            }
        }

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

    /// @notice This allows this contract to receive native currency funds from other contracts
    /// Uses event logging for UI reasons.
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
        withdraw();
    }

    /// @notice Returns array of accounts for current liquid split.
    function getAccounts() public view returns (address[] memory) {
        return tempAccounts;
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
}
