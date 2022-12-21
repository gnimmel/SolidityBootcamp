// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import "lib/forge-std/src/console2.sol";


contract ShameCoin is ERC20
{
    address immutable admin; 

    // The shame coin needs to have an administrator address that is set in the constructor
    constructor() ERC20("ShameCoin", "SHAME", 0) {
        admin = msg.sender;
    }

    // The decimal places should be set to 0
    function decimals() public pure override returns (uint8) {
		return 0;
	}

    // The administrator can send 1 shame coin at a time to other addresses (but keep the transfer function signature the same)

    // If non administrators try to transfer their shame coin, the transfer function will instead increase their balance by one

    // Non administrators can approve the administrator (and only the administrator) to spend one token on their behalf

    // The transfer from function should just reduce the balance of the holder

    function transfer(address to, uint256 amount) public virtual override returns (bool) 
    {
        if (msg.sender == admin) {
            require(amount == 1, "Can only transfer 1 at a time");
            _mint(to, 1);

            unchecked { balanceOf[to] += 1; }
        } else {
            _mint(msg.sender, 1);
            
            unchecked { balanceOf[msg.sender] += 1; }
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }
    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) 
    {
        require(amount == 1, "Can only transfer 1 at a time");

        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        // Should this use burn or just decrement balance ??
        //_burn(from, amount);
        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) 
    {
        require(spender == admin, "Spender must be admin");
        require(amount == 1, "Amount must be 1");

        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    // Write unit tests to show that the functionality is correct

    // Document the contract with Natspec, and produce docs
}