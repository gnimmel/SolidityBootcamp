// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Owned} from "@solmate/auth/Owned.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
//import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";

error TokenDoesNotExist();
error MaxSupplyReached();
error WrongTokenAmount();
error MaxNumPerTxReached();
error NoTokenBalance();
error IndexOutOfBounds();
error ContractPaused();

contract VolcanoNFT is ERC721, Owned 
{
    using Counters for Counters.Counter;
    Counters.Counter private supplyCounter;

    using Strings for uint256;

    struct Token {
        ERC20 token;
        string symbol;
        uint256 price;
    }

    Token[] private AllowedTokens;

    //LavaERC20 internal immutable lavaToken; // = ERC20('address to LAVA ERC20 Token');

    bool private isPaused = false;
    string private baseURI;

    uint256 internal constant MAX_SUPPLY = 1000;
    uint256 internal constant MAX_PER_TX = 2;

    address public vaultAddress = 0x9f61132889cB8738A386E2cdbA10eFA19D2880BD;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC721(_name, _symbol) Owned(msg.sender)
    {
        baseURI = _baseURI;
    }

    function addPayToken(
        ERC20 _token,
        string calldata _symbol,
        uint256 _price
    ) public onlyOwner {
        AllowedTokens.push(
            Token({
                token: _token,
                symbol: _symbol,
                price: (_price * 10 ** 18)
            })
        );
    }

    function mint(address _to, uint256 _numToMint, uint256 _tokenIndx) public payable
    {
        if (_tokenIndx >= AllowedTokens.length) revert IndexOutOfBounds();

        Token memory tokenData = AllowedTokens[_tokenIndx];
        
        require(_numToMint > 0);
        if (_numToMint > MAX_PER_TX) revert MaxNumPerTxReached();
        if (_numToMint + supplyCounter.current() > MAX_SUPPLY) revert MaxSupplyReached();
        if (msg.sender != owner) 
            if (msg.value < _numToMint * tokenData.price) revert WrongTokenAmount(); 

        unchecked {
            for (uint256 i = 0; i < _numToMint; i++) 
            {
                tokenData.token.transferFrom(msg.sender, address(this), tokenData.price);
                
                _mint(_to, supplyCounter.current());
                supplyCounter.increment();
            }
        }
    }

    function pause(bool _state) external onlyOwner() {
        isPaused = _state;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner() {
        baseURI = _newBaseURI;
    }
    function withdraw(uint256 _tokenIndx) external onlyOwner 
    {
        if (isPaused) revert ContractPaused();
        if (_tokenIndx >= AllowedTokens.length) revert IndexOutOfBounds();
        //require(_tokenIndx < AllowedTokens.length, "AllowedTokens: Index out of range");
        

        ERC20 theToken = AllowedTokens[_tokenIndx].token;
        if (theToken.balanceOf(address(this)) <= 0) revert NoTokenBalance(); 
        
        SafeTransferLib.safeTransfer(
            theToken, 
            vaultAddress, 
            theToken.balanceOf(address(this)));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (ownerOf(tokenId) == address(0))
            revert TokenDoesNotExist();

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }
}