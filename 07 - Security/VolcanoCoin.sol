// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract VolcanoCoin is Ownable
{
    uint256 totalSupply = 10000; // Just read a 2016 post stating that uint8 costs more gas than uint256 ...does this still hold true? I would assume that applies to 16, 32, etc? 
    
    struct Payment {
        uint256 amount;
        address recipient;
    }

    mapping(address => uint256) public balanceByAddress;
    mapping(address => Payment[]) public paymentsByAddress;
    
    event IncrementTotalSupply(uint256 newTotalSupply);
    event Sent(address from, address to, uint256 amount);

    error InsufficientBalance(uint256 requested, uint256 available);

    constructor() {
        //  owner = msg.sender;
        balanceByAddress[owner()] = totalSupply; // If we increment the total supply, the owner balance should probably also be incremented by that amount, No?
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    // shouldn't the increment amount be a function param?
    // A function hardcoded to increment by 1000 seems silly
    function incrementTotalSupplyBy(uint256 amnt) public onlyOwner returns (uint256 _totalSupply) {
        uint256 newSupply = totalSupply + amnt;
        totalSupply = newSupply;
        
        balanceByAddress[owner()] += amnt; // DO WE NEED THIS? Does the owner always control the total supply? 

        emit IncrementTotalSupply(newSupply);
        return newSupply;
    }

    function incrementTotalSupplyByThousand() public onlyOwner {
        incrementTotalSupplyBy(1000);
    }

    function transferAmountToAddress(uint256 amnt, address recipient) public {
        if (amnt > balanceByAddress[msg.sender]) // Oops, you're too poor
            revert InsufficientBalance({
                requested: amnt, 
                available: balanceByAddress[msg.sender]
                });

        balanceByAddress[msg.sender] -= amnt;
        balanceByAddress[recipient] += amnt;

        // record senders transaction history
        paymentsByAddress[msg.sender].push(Payment({amount: amnt, recipient: recipient}));
        
        emit Sent(msg.sender, recipient, amnt);
    }
}