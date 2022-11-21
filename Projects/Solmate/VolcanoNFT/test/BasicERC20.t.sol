// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "lib/forge-std/src/Test.sol";

import {BasicERC20} from "src/BasicERC20.sol";

contract BasicERC20Test is Test {
    using stdStorage for StdStorage;

    BasicERC20 token;

    //event LavaMinted();

    function setUp() external 
    {
        token = new BasicERC20("LavaToken", "LAVA", 18, 1000);
        
        console2.logString("BasicERC20 SETUP Test");
    }

    // VM Cheatcodes can be found in ./lib/forge-std/src/Vm.sol
    // Or at https://github.com/foundry-rs/forge-std
    function testMint() external {
       token.mint(address(this), 1000);
       assertEq(token.totalSupply(), 2000);
    }

    function testFailMintAsNotOwner() public {
        vm.prank(address(3));
        token.mint(address(0), 1000);
    }
}
