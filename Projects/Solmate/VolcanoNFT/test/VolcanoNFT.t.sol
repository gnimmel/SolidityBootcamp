// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "lib/forge-std/src/Test.sol";
import {console2} from "lib/forge-std/src/console2.sol";
//import "hardhat/console.sol";

import {VolcanoNFT} from "src/VolcanoNFT.sol";
import {BasicERC20} from "src/BasicERC20.sol";

contract VolcanoNFTTest is Test {
    using stdStorage for StdStorage;

    VolcanoNFT nft;
    BasicERC20 lavaToken;
    BasicERC20 ashToken;

    //event LavaMinted();

    function setUp() external 
    {
        nft = new VolcanoNFT("VolcanoNFT", "MAGMA", "");
        lavaToken = new BasicERC20("LavaToken", "LAVA", 18, 1000 * 10 ** 18);
        ashToken = new BasicERC20("AshToken", "ASH", 18, 1000 * 10 ** 18);
        //nft.addPayToken(lavaToken, lavaToken.symbol(), 10);
    }

    // VM Cheatcodes can be found in ./lib/forge-std/src/Vm.sol
    // Or at https://github.com/foundry-rs/forge-std
    function testFailOutOfRangePaymentOption() external {
        nft.mint(msg.sender, 1 , 11);
    }
    
    function testAddPayToken() external {
        nft.addPayToken(lavaToken, lavaToken.symbol(), 10);
        nft.addPayToken(ashToken, ashToken.symbol(), 100);

        assertEq(nft.getPaymentOptions().length, 2);
    }
        
    function testFailAddPayTokenNotOwner() external {
        vm.prank(address(3));
        nft.addPayToken(lavaToken, lavaToken.symbol(), 10);
    }

    function testMint() external {
        nft.addPayToken(lavaToken, lavaToken.symbol(), 10);
        nft.addPayToken(ashToken, ashToken.symbol(), 100);
        
        assertEq(nft.getPaymentOptions().length, 2);
        
        //console2.log(nft.balanceOf(address(this)));

        lavaToken.approve(address(nft), 10 ether);
        nft.mint{value: 10 ether}(address(2), 1, 0); // Using 'ether' for it's decimals

        console2.log(lavaToken.balanceOf(address(nft)));
    }

    function testFailWithdrawAsNotOwner() external {
        vm.prank(address(3));
        nft.withdraw(1);
    }

    function testWithdraw() external {
        helperAddPayTokens();
        nft.withdraw(1);
    }

    function helperAddPayTokens() internal {
        nft.addPayToken(lavaToken, lavaToken.symbol(), 10);
        nft.addPayToken(ashToken, ashToken.symbol(), 100);
    }
}
