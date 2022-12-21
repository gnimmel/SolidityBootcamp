// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Owned} from "@solmate/auth/Owned.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import "lib/forge-std/src/console2.sol";

error TokenDoesNotExist();

contract WidgetNFT is ERC721, Owned 
{
    using Counters for Counters.Counter;
    Counters.Counter private supplyCounter;

    using Strings for uint256;

    address private cryptoSaveAddress = address(0);
    address private svgModelAddress = address(0);

    constructor() ERC721("CryptoSaveWidgetNFT", "CSW") Owned(msg.sender) {
    }
  
    function mint() public payable {
        supplyCounter.increment();
        _mint(msg.sender, supplyCounter.current());
    }

    function setCryptoSaveAddress(address addr) public {
        cryptoSaveAddress = addr;
    }
    
    function setSvgModelAddress(address addr) public {
        svgModelAddress = addr;
    }

    function buildSvg() private view returns (bytes memory) 
    {
        ICryptoSave CryptoSave = ICryptoSave(cryptoSaveAddress);
        ISvgModel SvgModel = ISvgModel(svgModelAddress);

        string[8] memory parts;

        parts[0] = string.concat(
            "<svg viewBox='0 0 500 500' xmlns='http://www.w3.org/2000/svg'><path style='fill:#", 
            CryptoSave.getIsInMoney() ? "16cb19" : "cb1616" // BG_GREEN : BG_RED
            ); 

        parts[1] = "' d='M0 0h500v500H0z'/>";

        parts[2] = string.concat(
            CryptoSave.getIsInMoney() ? SvgModel.getSmileEmoji() : SvgModel.getPooEmoji(), 
            CryptoSave.getIsInMoney() ? SvgModel.getArrow(0) : SvgModel.getArrow(1)
            );

        parts[3] = string.concat(
            "<text style='fill:#dbfad4;font-family:Arial,sans-serif;font-size:64.6px;font-weight:700;stroke:#cceb68;white-space:pre' transform='matrix(.51199 0 0 .5273 -46.467 211.966)' x='211.757' y='466.61'>", 
            CryptoSave.strLifetimePercent()
            );

        parts[4] = "%</text><text style='fill:#dbfad4;font-family:Arial,sans-serif;font-size:64.6px;font-weight:700;stroke:#cceb68;white-space:pre;text-anchor:middle' transform='matrix(.51199 0 0 .5273 134.307 209.57)' x='211.757' y='466.61'>";

        parts[5] = string.concat(CryptoSave.assetHeldSymbol(), "</text>"); // Is concat cheaper than abi.encode ??
        
        parts[6] = string.concat(
            CryptoSave.getIsInMoney() ? SvgModel.getArrow(2) : SvgModel.getArrow(3), 
            "<text style='fill:#dbfad4;font-family:Arial,sans-serif;font-size:64.6px;font-weight:700;stroke:#cceb68;white-space:pre' transform='matrix(.51199 0 0 .5273 290.812 211.966)' x='211.757' y='466.61'>"
            );

        parts[7] = string.concat(CryptoSave.strSwapPercent(), SvgModel.getStaticElements());

        bytes memory image = abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(
                bytes(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7]))));
        return image;
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
                    '{"name": "', Strings.toString(tokenId), '",',
                    '"image_data": "', buildSvg(), '",',
                    '"description": "Keep your wallet heavy and your head above water"}'
                )
            ))
        );

        return string(abi.encodePacked('data:application/json;base64,', json));
    }
}

// Interface to datapoints in CryptoSave
interface ICryptoSave {
    function getIsInMoney() external view returns (bool);
    function strLifetimePercent() external view returns (string memory);
    function strSwapPercent() external view returns (string memory);
    function assetHeldSymbol() external view returns (string memory);
}

// The SVG source code
interface ISvgModel {
    function getSmileEmoji() external view returns (string memory);
    function getPooEmoji() external view returns (string memory);
    function getArrow(uint8 arrowType) external view returns (string memory);
    function getStaticElements() external view returns (string memory);
}