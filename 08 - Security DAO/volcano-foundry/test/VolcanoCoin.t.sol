// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/VolcanoCoin.sol";



contract VolcanoCoinTest is Test {
    VolcanoCoin public coin;

    function setUp() public {
        coin = new VolcanoCoin();
    }

    function testSupply() public {
        assertEq(coin.getTotalSupply(), 10000);
    }

    function testIncrementSupply() public {
        coin.incrementTotalSupplyByThousand();
        assertEq(coin.getTotalSupply(), 11000);
    }

    function testOwner() public {
        assertEq(coin.owner(),address(this));
    }

    function testFailIncrementAsNotOwner() public {
        vm.prank(address(3));
        coin.incrementTotalSupplyByThousand();
    }
}
