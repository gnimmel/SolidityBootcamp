// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {Owned} from "@solmate/auth/Owned.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";

// CONTRACT ADDRESSES
// LAVA: 0x9AA889A1706fb7604e75F1C573891555412939ce

contract BasicERC20 is ERC20, Owned 
{
    constructor(
        string memory _name,    // Volcano
        string memory _symbol,  // LAVA
        uint8 _decimals,        // 18 (same as ETH)
        uint256 _initialSupply  // 1,000,000
    ) ERC20(_name, _symbol, _decimals) Owned(msg.sender)
    {
        _mint(msg.sender, _initialSupply);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burnFrom(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
    
}