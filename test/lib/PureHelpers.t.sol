// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/lib/PureHelpers.sol";

contract PureHelpersTest is Test, PureHelpers {
    function setUp() public {}

    /// -----------------------------------------------------------------------
    /// correctness tests
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// correctness tests - basic
    /// -----------------------------------------------------------------------

    function testCan_sortAddresses() public pure {
        address[] memory randAddresses = new address[](5);
        randAddresses[0] = address(0);
        randAddresses[1] = address(1);
        randAddresses[2] = address(5);
        randAddresses[3] = address(4);
        randAddresses[4] = address(1);

        address[] memory sortedAddresses = _sortAddresses(randAddresses);

        for (uint256 i = 1; i < sortedAddresses.length; i++) {
            assert(sortedAddresses[i - 1] <= sortedAddresses[i]);
        }
    }

    function testCan_uniqArrays() public {
        address[] memory sortedAddresses = new address[](5);
        sortedAddresses[0] = address(0);
        sortedAddresses[1] = address(0);
        sortedAddresses[2] = address(1);
        sortedAddresses[3] = address(2);
        sortedAddresses[4] = address(2);

        address[] memory uniqAddresses = new address[](3);
        uniqAddresses[0] = address(0);
        uniqAddresses[1] = address(1);
        uniqAddresses[2] = address(2);

        assertEq(_uniqueAddresses(sortedAddresses), uniqAddresses);
    }

    function testCan_countUniqueRecipients() public {
        address[] memory sortedAddresses = new address[](5);
        sortedAddresses[0] = address(0);
        sortedAddresses[1] = address(0);
        sortedAddresses[2] = address(1);
        sortedAddresses[3] = address(2);
        sortedAddresses[4] = address(2);

        uint256 uniqAddresses = _countUniqueRecipients(sortedAddresses);

        assertEq(uniqAddresses, 3);
    }

    /// -----------------------------------------------------------------------
    /// correctness tests - fuzzing
    /// -----------------------------------------------------------------------

    function testCan_sortAddresses(bytes32 seed, uint8 len) public {
        vm.assume(len > 1);

        address[] memory randAddresses = genRandAddressArray(seed, len);

        emit log_array(randAddresses);

        address[] memory sortedAddresses = _sortAddresses(randAddresses);
        emit log_array(sortedAddresses);

        for (uint256 i = 1; i < len; i++) {
            assert(sortedAddresses[i - 1] <= sortedAddresses[i]);
        }
    }

    /// -----------------------------------------------------------------------
    /// helper fns
    /// -----------------------------------------------------------------------

    function genRandAddressArray(bytes32 seed, uint8 len) internal pure returns (address[] memory addresses) {
        addresses = new address[](len);

        bytes32 _seed = seed;
        for (uint256 i = 0; i < len; i++) {
            _seed = keccak256(abi.encodePacked(_seed));
            addresses[i] = address(bytes20(_seed));
        }
    }
}
