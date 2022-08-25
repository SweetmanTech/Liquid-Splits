// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "erc721a/contracts/ERC721A.sol";
import "../interfaces/IPuzzleDrop.sol";

contract PuzzleDrop is ERC721A, IPuzzleDrop {
    /// @notice Price for Single
    uint256 public singlePrice = 22200000000000000;
    /// @notice Price for Single
    uint256 public bundlePrice = 33300000000000000;
    /// @notice Public Sale Start Time
    uint64 public publicSaleStart = 0;
    /// @notice Public Sale End Time
    uint64 public publicSaleEnd = 1692974064;

    /// @notice Sale is inactive
    error Sale_Inactive();
    /// @notice Wrong price for purchase
    error Purchase_WrongPrice(uint256 correctPrice);

    constructor(string memory _name, string memory _symbol)
        ERC721A(_name, _symbol)
    {}

    /// @notice Public sale active
    modifier onlyPublicSaleActive() {
        if (!_publicSaleActive()) {
            revert Sale_Inactive();
        }

        _;
    }

    /// @notice Public sale active
    modifier onlyValidPrice(uint256 _price, uint256 _quantity) {
        if (msg.value != _price * _quantity) {
            revert Purchase_WrongPrice(_price * _quantity);
        }

        _;
    }

    /// @notice Public sale active
    function _publicSaleActive() internal view returns (bool) {
        return
            publicSaleStart <= block.timestamp &&
            publicSaleEnd > block.timestamp;
    }

    /// @notice Sale details
    /// @return IERC721Drop.SaleDetails sale information details
    function saleDetails() external view returns (SaleDetails memory) {
        return
            SaleDetails({
                publicSaleActive: _publicSaleActive(),
                presaleActive: false,
                publicSalePrice: singlePrice,
                publicSaleBundlePrice: bundlePrice,
                publicSaleStart: publicSaleStart,
                publicSaleEnd: publicSaleEnd,
                presaleStart: 0,
                presaleEnd: 0,
                presaleMerkleRoot: 0x0000000000000000000000000000000000000000000000000000000000000000,
                totalMinted: _totalMinted(),
                maxSupply: 1000000,
                maxSalePurchasePerAddress: 0
            });
    }

    /// @notice Returns the starting token ID.
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}
