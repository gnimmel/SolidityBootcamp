// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Owned} from "@solmate/auth/Owned.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
//import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import "@solmate/utils/ReentrancyGuard.sol";
import "lib/forge-std/src/console2.sol";

error TokenDoesNotExist();
error MaxSupplyReached();
error WrongTokenAmount();
error MaxNumPerTxReached();
error NoTokenBalance();
error InvalidTokenIndex();
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

    Token[] private AllowedPaymentTokens;

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
        //console2.log("VolcanoNFT constructor");
    }

    function addPayToken(
        ERC20 _token,
        string calldata _symbol,
        uint256 _price
    ) public onlyOwner {
        //for (uint256 i = 0; i < AllowedPaymentTokens.length; i++) {}

        AllowedPaymentTokens.push(
            Token({
                token: _token,
                symbol: _symbol,
                price: (_price * 10 ** 18)
            })
        );
    }

    function getPaymentOptions() external view returns(Token[] memory) {
        return AllowedPaymentTokens;
    }

    function mint(address _to, uint256 _numToMint, uint256 _tokenIndx) public payable
    {
        if (isPaused) revert ContractPaused();
        if (_tokenIndx >= AllowedPaymentTokens.length) revert InvalidTokenIndex();

        Token memory tokenObj = AllowedPaymentTokens[_tokenIndx];
        //console2.log("function mint:", AllowedPaymentTokens[_tokenIndx].symbol);

        require(_numToMint > 0);
        if (_numToMint > MAX_PER_TX) revert MaxNumPerTxReached();
        if (_numToMint + supplyCounter.current() > MAX_SUPPLY) revert MaxSupplyReached();
        //if (msg.sender != owner) 
        //console2.log(msg.value, " < ", _numToMint * tokenObj.price);
        
        if (msg.value < _numToMint * tokenObj.price) revert WrongTokenAmount();

        unchecked {
            for (uint256 i = 0; i < _numToMint; i++) 
            {
                //bool success = tokenObj.token.approve(address(this), tokenObj.price);
                //console2.log(success);
                //console2.log(tokenObj.token.allowance(msg.sender, address(this)));
                
                require(tokenObj.token.allowance(msg.sender, address(this)) >= tokenObj.price, "Insufficient Allowance");

                //tokenObj.token.transferFrom(msg.sender, address(this), tokenObj.price);
                SafeTransferLib.safeTransferFrom(tokenObj.token, msg.sender, address(this), tokenObj.price); 

                supplyCounter.increment();
                _mint(_to, supplyCounter.current());                
            }
        }
        //console2.log(tokenObj.token.balanceOf(address(this)));
    }

    function pause(bool _state) external onlyOwner() {
        isPaused = _state;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner() {
        baseURI = _newBaseURI;
    }

    function withdraw(uint256 _tokenIndx) external onlyOwner //nonReentrant
    {
        if (isPaused) revert ContractPaused();
        if (_tokenIndx >= AllowedPaymentTokens.length) revert InvalidTokenIndex();
        //require(_tokenIndx < AllowedTokens.length, "AllowedTokens: Index out of range");
        

        ERC20 theToken = AllowedPaymentTokens[_tokenIndx].token;
        if (theToken.balanceOf(address(this)) <= 0) revert NoTokenBalance(); 
        
        SafeTransferLib.safeTransfer(
            theToken, 
            vaultAddress, 
            theToken.balanceOf(address(this)));
    }

    function getSvg(uint256 tokenId) private pure returns (string memory) 
    {
        string[3] memory parts;
        parts[0] = "<svg xmlns='http://www.w3.org/2000/svg' xml:space='preserve' width='300' height='300' version='1.0'> <text fill='#BD6F00' font-family='DejaVu Serif Condensed' font-size='32.462' font-style='italic' font-weight='700' alignment-baseline='middle' text-anchor='middle' x='150' y='215'>C&apos;est un volcan</text><text fill='#BD6F00' font-family='DejaVu Serif Condensed' font-size='60.462' font-style='italic' font-weight='700' alignment-baseline='middle' text-anchor='middle' x='150' y='270'>";
        parts[1] = Strings.toString(tokenId);
        parts[2] = "</text><path fill='#FFC916' stroke='#000' stroke-width='3' d='M46.41 68.192s5.768 10.994 13.25 19.67c7.479 8.675 81.02 42.017 124.352 42.239 43.334.226 84.48-14.171 85.789-12.305 1.311 1.867 4.232 7.616 3.953 9.204-.279 1.587 3.965 33.427-42.074 49.586-46.037 16.156-160.595 10.03-183.813-50.364-6.746-17.549.846-25.385.846-25.385s-9.339-17.12-16.929-20.149c-6.579-2.626-5.368-4.868-4.735-7.541.631-2.671.684-5.772 4.845-8.971 4.161-3.2 12.808-3.977 12.529-2.389s1.987 6.405 1.987 6.405z'/><path fill='#BD6F00' d='M46.666 107.845s10.367 36.803 85.351 53.738c64.55 14.582 119.283 4.854 137.037-14.293 0 0-23.295 54.513-152.371 28.957-7.568-1.498-75.058-22.804-70.017-68.402z' opacity='.77'/><path fill='#9CC902' d='M41.473 62.745c4.187 2.137 13.926 24.208 23.755 27.893 9.83 3.687-6.305 6.098-8.095 7.911-1.792 1.814-6.305 6.096-9.106 8.062-2.798 1.966 2.678-9.678-3.193-14.471-5.869-4.793-10.529-11.829-13.405-10.367-2.875 1.459 6.138-21.022 10.044-19.028z' opacity='.5'/><path fill='#412800' d='M44.221 63.881s-3.885 1.611-4.517 4.284c-.631 2.671 5.113 10.06 8.59 12.633 3.477 2.572-8.166-2.903-10.763-3.031-2.597-.128-7.991 1.709-7.991 1.709s-1.361 1.234-2.318-1.715.232-8.797 1.667-9.527c1.438-.73 5.802-6.021 5.802-6.021s7.186-3.652 9.53 1.668z' opacity='.83'/><path fill='#412800' d='m273.164 131.217-6.641-12.773s-.48-1.137 1.604-1.09c2.084.046 8.211 8.187 8.211 8.187s.723 5.369-3.174 5.676z'/><path fill='#FFF' d='M269.012 129.771s-43.504 40.005-123.378 19.468c-79.873-20.537-84.85-43.504-84.85-43.504s6.08-7.609 8.248-6.902c2.167.707 66.52 39.03 107.892 39.03 44.846-.001 81.455-13.72 84.908-14.752 3.455-1.031 7.889 4.493 7.18 6.66z' opacity='.3'/><path fill='#412800' d='M263.965 140.833c-.227.104-1.402-.351-1.402-.351s.678-2.243 1.186-1.868c.503.376.954 1.883.216 2.219zm-9.287 5.193c-.232-.09-.793-1.191-.793-1.191s1.938-.986 2.066-.396c.125.59-.519 1.876-1.273 1.587zM121.997 120.75c.118-.166 1.109-.38 1.109-.38s.389 1.75-.106 1.726c-.497-.022-1.388-.808-1.003-1.346zm140.864 27.438c-.541.317-1.754-1.191-1.168-1.858.586-.668 1.15-1.48 1.605-1.185.456.294.886 2.262-.437 3.043zM59.976 131.409c-.698.269-2.072-.688-1.294-1.203.779-.516 1.544-1.13 2.084-.961.539.17.911 1.51-.79 2.164zm58.853-9.823c-.411.223-1.302-.807-.86-1.271.446-.467.876-1.029 1.214-.83.337.199.643 1.552-.354 2.101zm97.989 13.292c-.025.376-1.104.545-1.227.042-.123-.506-.316-1.041-.037-1.187s1.323.228 1.264 1.145z'/><path fill='#412800' d='M125.386 162.06s-3.123-3.656-4.99-2.348c-1.865 1.31-4.688-.33-4.688-.33s1.692-5.923 3.002-4.058c1.31 1.867 9.049 5.349 9.049 5.349l-2.373 1.387zm-12.147-5.402s-2.544-3.228-4.989-2.346c-2.446.878-1.994 3.905-1.994 3.905l6.983-1.559z' opacity='.76'/></svg>";
  
        return string(abi.encodePacked(parts[0], parts[1], parts[2]));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (ownerOf(tokenId) == address(0))
            revert TokenDoesNotExist();

        
        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"name": "', Strings.toString(tokenId), '",',  // OR: tokenId.toString(); ??
                    '"image_data": "', getSvg(tokenId), '",',
                    '"description": "A volcano NFT that looks like a banana"}'
                )
            ))
        );

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) // Return the NFTStorage Asset
                : string(abi.encodePacked('data:application/json;base64,', json)); // Return the onchain SVG
    }
}