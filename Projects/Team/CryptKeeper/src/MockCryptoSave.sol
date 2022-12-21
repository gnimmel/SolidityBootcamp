// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

contract CryptoSave {
    uint256 public totalGasUsed;    
    string public strLifetimePercent;
    string public strSwapPercent;
    string public assetHeldSymbol = 'ETH';

    bool internal isInMoney;

    function getIsInMoney() public view returns(bool) {
       return isInMoney;
    }

    // Test setters
    function toggleIsInMoney() public {
        isInMoney = !isInMoney;
    }

    function setLifetimePercent(string memory str) public {
        strLifetimePercent = str;
    }

    function setSwapPercent(string memory str) public {
        strSwapPercent = str;
    }

    function setSymbol(string memory str) public {
        assetHeldSymbol = str;
    }
}