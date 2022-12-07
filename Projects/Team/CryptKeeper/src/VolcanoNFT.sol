// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

//import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Owned} from "@solmate/auth/Owned.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
//import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
//import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
//import "@solmate/utils/ReentrancyGuard.sol";
import "lib/forge-std/src/console2.sol";

error TokenDoesNotExist();

contract keeperNFT is ERC721, Owned 
{
    using Counters for Counters.Counter;
    Counters.Counter private supplyCounter;

    using Strings for uint256;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) Owned(msg.sender)
    {
    }
  
    function mint() public payable
    {
        supplyCounter.increment();
        _mint(msg.sender, supplyCounter.current());
    }

    bool private isInMoney = true; // The update func should toggle this

    string internal strLifetimePercent = '6.9';
    string internal strSwapPercent = '4.2';
    string internal assetHeldSymbol = 'ETH';

    // STATE CHANGE TESTS
    function toggleIsInMoney() public returns (bool) {
        return isInMoney = !isInMoney;
        //return isInMoney;
    }

    function setPercentages(string memory lifetime, string memory swap) public {
        strLifetimePercent = lifetime;
        strSwapPercent = swap;
    }

    function setAssetSymbol(string memory str) public{
        assetHeldSymbol = str;
    }

    // WARNING: THIS MIGHT BE STUPID EXPENSIVE ???
    function buildSvg() private view returns (bytes memory) 
    {
        string memory EMOJI_SMILE = "<path class='st0' d='M45.54 2.11c32.77-8.78 66.45 10.67 75.23 43.43 8.78 32.77-10.67 66.45-43.43 75.23-32.77 8.78-66.45-10.67-75.23-43.43-8.78-32.77 10.66-66.45 43.43-75.23z' style='clip-rule:evenodd;fill:#fbd433;fill-rule:evenodd' transform='translate(89.773 20.27) scale(2.55701)'/><path class='st1' d='M45.78 31.71c4.3 0 7.78 6.6 7.78 14.75s-3.48 14.75-7.78 14.75S38 54.61 38 46.46c0-8.14 3.48-14.75 7.78-14.75zM22.43 80.59c.42-7.93 4.53-11.46 11.83-11.76l-5.96 5.93c16.69 21.63 51.01 21.16 65.78-.04l-5.47-5.44c7.3.3 11.4 3.84 11.83 11.76l-3.96-3.93c-16.54 28.07-51.56 29.07-70.7.15l-3.35 3.33zM77.1 31.71c4.3 0 7.78 6.6 7.78 14.75s-3.49 14.75-7.78 14.75-7.78-6.6-7.78-14.75c-.01-8.14 3.48-14.75 7.78-14.75z' style='clip-rule:evenodd;fill:#141518;fill-rule:evenodd' transform='translate(89.773 20.27) scale(2.55701)'/>";
        string memory EMOJI_POO = "<path class='st1' d='M166.3 376.7c-3.6-9.1-5.6-18.2-5.9-27.6-.8-24.1 9.2-42.7 28.8-56.4 6.7-4.6 13.9-8.2 21.4-11.2.8-.3 1.6-.6 2.5-1-1.5-5.6-2.5-11.2-3-16.9-1.6-18.6 1-36.3 12-51.8 8.8-12.5 20.4-21.2 35.7-24.6 7.8-1.7 10.8-6 8.3-13.8-3.9-12.1-.8-22.6 5.7-32.7 1.8-2.8 3.8-5.4 5.7-8.2.5-.8 1.1-1.5 1.7-2.2 5.2-7.2 6.2-15.1 3.4-23.5-1.2-3.4-2.4-6.7-3.5-10.1-4.8-14.8 5.5-24.3 17.6-24.8 6.3-.3 12.3 1.1 18.3 2.8 30.2 8.5 56.3 24.5 79.7 45.1 11.3 9.9 22.3 20 31.7 31.7 10.6 13.2 16.5 28 15.9 45.2-.1 3.1-.6 6.1-1.1 9.3 5.2.6 10.3 1.7 15.1 3.5 19.2 7.3 29.9 21.4 33 41.5 1.3 8.6 1 17.1-.1 25.9 1.8.5 3.5.9 5.1 1.4 17.2 5.2 31.4 14.5 40.6 30.4 6.8 11.7 8.6 24.6 8.1 37.9-.5 10.5-2.7 20.7-5.7 30.8.8.9 1.9 1 2.9 1.4 13.6 5.7 25.7 13.6 35.3 24.9 13.5 15.8 17.9 34.2 15.1 54.5-1.2 9.1-3.3 17.9-7.2 26.2-6.7 13.9-17.9 22.8-31.8 28.7-13.5 5.7-27.7 8.7-42.1 10.9-24.1 3.8-48.3 6-72.6 7.4-14.7.8-29.4-1.1-44-2.6-13.5-1.4-27.1-2.8-40.5-4.8-15.6-2.3-31.1-4.7-46.8-6.4-25.5-2.8-50.6-1.4-75.4 5.4-12.5 3.4-25.2 6.6-38.1 8.3-14.5 1.9-28.9 1.6-42.6-4.2-18.5-7.9-30.3-21.8-35.1-41.1-7.3-29.1-3.1-56.6 14.1-81.5 8.9-12.8 21.4-21.2 35.7-27 .6-.2 1.2-.5 2.1-.8zm17.3 9.6c-2.6.6-4.8 1-7 1.5-8.9 2.4-17.1 6.1-24.4 11.6-9.8 7.4-16.8 16.9-20.8 28.6-3.5 10.2-5.2 20.6-4.1 31.5.8 8.8 2 17.4 5.6 25.6 3.1 7 7.2 13.1 12.9 18.3 8 7.3 17.8 10.7 28.1 12.8 7.6 1.5 15.4 1.5 23.1 1 5-.3 10-.8 14.8-2.3 8.9-2.9 17.9-5.8 27.1-7.8 10.7-2.4 21.5-4.6 32.5-5.2 9-.5 17.9-.9 26.8 1.1 4.9 1.1 9.9 2.2 14.9 3 9.7 1.5 19.3 3.3 29.1 4.3 6.7.7 13.4 1.7 20.1 2.3 7 .7 14 1.2 21 1.7 11 .9 22 1.3 33 1.8 13.8.6 27.6-.6 41.4-1.8 8.8-.8 17.6-1.4 26.3-2.4 10.7-1.2 21.5-2.5 32.1-4.8 9.6-2.1 19.2-4.3 28.1-8.5 11.1-5.2 20.4-12.3 25.7-23.9 1.7-3.6 3-7.4 4-11.2 2.3-9.7 3.1-19.4.7-29.2-1.9-7.6-5.3-14.3-10.2-20.5-7.5-9.6-17.2-16.2-27.7-21.9-4.7-2.6-9.8-4.2-14.8-6.1-1.6-.6-1.8-1.3-1.2-2.8 3.5-8.7 6.3-17.5 7.3-26.8 1.2-10.6.3-21-3.7-30.9-3.8-9.6-10.2-17.3-18.1-23.9-9-7.4-19.3-12.1-30.4-15.5-1.3-.4-1.8-1-1.5-2.2 1.3-4.6 2.1-9.2 2.6-13.9.9-9.1.3-18-3.6-26.4-5.3-11.6-14.7-18.4-26.4-22.5-7-2.5-14.2-4.1-21.7-4-.8 0-1.6.1-2.1-.9 2-5.1 3.8-10.3 4-16 .3-9.9-2.4-19.1-6.6-28-7-14.9-17.8-26.9-29.5-38.2-5-4.9-10.4-9.5-15.5-14.2-9.5-8.8-20.3-15.6-31.9-21.1-10.3-4.9-20.9-8.8-32.2-10.6-5.7-.9-11.4-1.7-17.1 0-2.7.8-4.2 3.4-3.6 6.1.3 1.5.9 2.9 1.6 4.3 1.9 3.8 5.1 6.3 7.9 9.3 4.7 5.2 5.8 12.7 1.4 18.6-3.5 4.7-7.2 9.1-10.8 13.7-5.6 7.2-10 14.9-12.9 23.5-2.4 7.2-3.1 14.6.8 21.7 1 1.9 2.5 3.5 3.9 5.4-4.7 2.1-9.4 3.7-13.8 5.7-15.2 7-29.1 15.6-39 29.7-6.9 9.8-10 20.8-9.9 32.6.1 8 1.9 15.8 5.2 23.2 1 2.2 2 4.4 3 6.8-2.9 1-5.5 2-8.2 2.9-7.6 2.6-14.6 6.2-21.2 10.9-5.3 3.8-9.4 8.5-13.3 13.8-3.5 4.7-5.9 9.7-7.4 15.2-3.8 13.8-2.8 27.5.9 41.2 1.2 4.7 3 9.1 4.7 13.8z' style='fill:#522d15' transform='matrix(.69598 0 0 .67924 5.401 -34.85)'/><path class='st2' d='M183.6 386.3c-1.6-4.7-3.5-9.1-4.7-13.6-3.6-13.7-4.7-27.4-.9-41.2 1.5-5.4 4-10.5 7.4-15.2 3.9-5.2 8-10 13.3-13.8 6.5-4.7 13.5-8.4 21.2-10.9 2.6-.9 5.3-1.9 8.2-2.9-1.1-2.4-2.1-4.6-3-6.8-3.3-7.4-5.1-15.2-5.2-23.2-.1-11.7 3-22.8 9.9-32.6 9.9-14 23.8-22.7 39-29.7 4.5-2.1 9.1-3.6 13.8-5.7-1.4-1.9-2.8-3.6-3.9-5.4-3.9-7-3.2-14.4-.8-21.7 2.9-8.6 7.3-16.3 12.9-23.5 3.6-4.6 7.3-9.1 10.8-13.7 4.4-5.9 3.4-13.4-1.4-18.6-2.7-3-6-5.5-7.9-9.3-.7-1.4-1.2-2.8-1.6-4.3-.6-2.7.9-5.3 3.6-6.1 5.7-1.7 11.4-1 17.1 0 11.3 1.8 21.9 5.7 32.2 10.6 11.6 5.6 22.4 12.4 31.9 21.1 5.2 4.8 10.5 9.4 15.5 14.2 11.6 11.3 22.5 23.3 29.5 38.2 4.2 8.9 6.8 18.1 6.6 28-.1 5.7-1.9 10.9-4 16 .5 1 1.3.9 2.1.9 7.5-.1 14.7 1.6 21.7 4 11.6 4.1 21.1 10.8 26.4 22.5 3.8 8.4 4.5 17.3 3.6 26.4-.5 4.7-1.3 9.4-2.6 13.9-.3 1.2.2 1.8 1.5 2.2 11 3.4 21.4 8 30.4 15.5 7.9 6.5 14.2 14.3 18.1 23.9 4 10 4.8 20.3 3.7 30.9-1 9.4-3.9 18.2-7.3 26.8-.6 1.5-.4 2.2 1.2 2.8 5 1.9 10.1 3.5 14.8 6.1 10.5 5.7 20.2 12.3 27.7 21.9 4.9 6.2 8.3 13 10.2 20.5 2.4 9.8 1.6 19.5-.7 29.2-.9 3.9-2.3 7.6-4 11.2-5.3 11.5-14.6 18.6-25.7 23.9-8.9 4.2-18.5 6.4-28.1 8.5-10.6 2.3-21.3 3.6-32.1 4.8-8.7 1-17.5 1.6-26.3 2.4-13.8 1.2-27.6 2.4-41.4 1.8-11-.5-22-.9-33-1.8-7-.6-14-1.1-21-1.7-6.7-.6-13.4-1.6-20.1-2.3-9.8-1-19.4-2.8-29.1-4.3-5-.8-10-1.9-14.9-3-8.9-2-17.8-1.6-26.8-1.1-11 .6-21.8 2.9-32.5 5.2-9.2 2-18.1 4.9-27.1 7.8-4.8 1.5-9.8 2-14.8 2.3-7.7.4-15.5.5-23.1-1-10.3-2.1-20-5.5-28.1-12.8-5.7-5.2-9.8-11.3-12.9-18.3-3.6-8.2-4.7-16.8-5.6-25.6-1-10.9.7-21.3 4.1-31.5 4-11.7 11.1-21.2 20.8-28.6 7.3-5.5 15.6-9.3 24.4-11.6 2.1-.7 4.4-1.1 7-1.7Zm286.1-64.4c-.1-1.2-.2-3.3-.3-5.4-.6-12.7-4.7-24.6-11.4-35.1-3.9-6.1-9.3-11.7-16.1-15.5-14.4-8.1-28.6-8.3-42.7.3-6.8 4.2-12.5 9.8-16.4 16.7-13.4 23.3-14.7 47.5-4 72.1 5.3 12.1 13.6 21.8 26 27.3 5.5 2.4 11.3 3.9 17.5 3.8 4.7-.1 8.9-1.6 13.2-3.2 3.6-1.4 7.1-3.1 10.1-5.4 4.2-3.2 8-6.9 11-11.5 4.3-6.6 7.8-13.4 10-21 2.1-7.2 3-14.6 3.1-23.1Zm-137.6 2.9c-.5-18.1-5.5-35.4-19.5-49.3-6.1-6.1-13.3-10.3-21.8-12-11.9-2.3-22.7.4-32.2 7.7-12.3 9.4-19.3 22.2-22.6 37.1-2.8 13-2.7 26 1 38.9 2.3 8 5.6 15.5 10.7 22.1 7.1 9.3 15.5 16.6 27.5 18.7 9.4 1.7 18.3.5 26.6-3.8 5.3-2.8 9.9-6.8 13.8-11.4 11.5-13.6 16.1-29.5 16.5-48Z' style='fill:#845329' transform='matrix(.69598 0 0 .67924 5.401 -34.85)'/><path class='st3' d='M469.7 321.9c-.1 8.5-1.1 15.9-3.1 23.1-2.2 7.6-5.6 14.4-10 21-3 4.6-6.8 8.3-11 11.5-3 2.3-6.5 4-10.1 5.4-4.3 1.6-8.5 3.1-13.2 3.2-6.2.1-12-1.3-17.5-3.8-12.4-5.5-20.7-15.2-26-27.3-10.7-24.6-9.4-48.8 4-72.1 4-6.9 9.6-12.5 16.4-16.7 14.1-8.7 28.3-8.4 42.7-.3 6.8 3.8 12.2 9.4 16.1 15.5 6.7 10.5 10.8 22.4 11.4 35.1.2 2.1.3 4.3.3 5.4zm-25.6 4.8c0-9-1.2-15.6-4.2-21.9-1.2-2.5-2.6-4.8-4.3-6.9-8.8-10.9-22.3-10.9-30.9.1-7.4 9.5-9.3 20.5-8.1 32.1.9 8.7 3.8 16.7 10.1 23.2 7.8 8 18.9 8 26.8.1 7.8-8 10.3-18 10.6-26.7zm-112-1.9c-.4 18.5-5 34.4-16.4 48-3.9 4.6-8.5 8.7-13.8 11.4-8.3 4.3-17.2 5.5-26.6 3.8-12.1-2.1-20.4-9.4-27.5-18.7-5.1-6.6-8.5-14.1-10.7-22.1-3.6-12.9-3.8-25.9-1-38.9 3.2-14.9 10.2-27.7 22.6-37.1 9.6-7.3 20.3-10 32.2-7.7 8.5 1.7 15.7 5.9 21.8 12 13.8 13.9 18.9 31.2 19.4 49.3zm-73.8.2c.1 10.7 2.4 20.1 9.1 28 8.2 9.6 19.9 9.9 28.7.9 1.6-1.7 3-3.5 4.1-5.5 4.7-8 6.2-16.7 5.7-25.8-.6-9.3-3.2-17.9-9.6-25-7.9-8.8-19.4-9.1-27.6-.7-7.7 8-10.1 17.9-10.4 28.1z' style='fill:#fefefe' transform='matrix(.69598 0 0 .67924 5.401 -34.85)'/><path class='st3' d='M353.6 461.5c-32.9-.6-59.5-14.1-80.3-39.3-1.2-1.5-2.3-3.2-3-5-2.3-5.7.2-9.7 6.4-10.4 7.9-.9 15.8.4 23.7.9 8.9.5 17.8 1.2 26.7 1.4 4.5.1 9 .4 13.5.4 11.7.1 23.3.3 35-.1 11.9-.4 23.9-1.1 35.8-2.2 5.8-.5 11.4-2.4 17.3-1.8 2.7.2 5.1.9 7.3 2.5 2.3 1.7 2.7 4 2.1 6.6-.7 3-2 5.6-4 7.9-19.4 22.2-43.2 36.3-73 39-2.6.3-5 .1-7.5.1Z' style='fill:#fefefe' transform='matrix(-.69598 0 0 -.67924 498.021 553.95)'/><path class='st1' d='M444.1 326.7c-.3 8.7-2.7 18.7-10.5 26.6-7.8 8-18.9 7.9-26.8-.1-6.3-6.4-9.2-14.4-10.1-23.2-1.2-11.6.7-22.6 8.1-32.1 8.6-11.1 22.1-11.1 30.9-.1 1.7 2.1 3.1 4.4 4.3 6.9 2.8 6.4 4.1 13.1 4.1 22zM258.3 325c.3-10.1 2.7-20.1 10.4-28 8.3-8.4 19.7-8.1 27.6.7 6.4 7.1 9.1 15.7 9.6 25 .5 9.1-1 17.8-5.7 25.8-1.2 2-2.5 3.8-4.1 5.5-8.8 9-20.5 8.7-28.7-.9-6.7-8-9-17.4-9.1-28.1z' style='fill:#522d15' transform='matrix(.69598 0 0 .67924 5.401 -34.85)'/>";
        string memory ARROW_LEFT_UP = "<path d='M18.988 447.717h6.749v17.753h17.244v-17.753h6.748L34.36 425.906' style='fill:#c0fdc0'/>";
        string memory ARROW_LEFT_DOWN = "<path d='M19.012 447.753h6.749v17.753h17.244v-17.753h6.748l-15.369-21.811' style='fill:#c0fdc0' transform='rotate(180 34.382 445.724)'/>";
        string memory ARROW_RIGHT_UP = "<path d='M356.267 447.717h6.749v17.753h17.244v-17.753h6.748l-15.369-21.811' style='fill:#c0fdc0'/>";
        string memory ARROW_RIGHT_DOWN = "<path d='M356.291 447.753h6.749v17.753h17.244v-17.753h6.748l-15.369-21.811' style='fill:#c0fdc0' transform='rotate(180 371.661 445.724)'/>";

        // Build the SVG

        string[8] memory parts;

        parts[0] = string.concat("<svg viewBox='0 0 500 500' xmlns='http://www.w3.org/2000/svg'><path style='fill:#", isInMoney ? "16cb19" : "cb1616"); // BG_GREEN : BG_RED

        parts[1] = "' d='M0 0h500v500H0z'/>";

        parts[2] = string.concat(isInMoney ? EMOJI_SMILE : EMOJI_POO, isInMoney ? ARROW_LEFT_UP : ARROW_LEFT_DOWN);

        parts[3] = string.concat("<text style='fill:#dbfad4;font-family:Arial,sans-serif;font-size:64.6px;font-weight:700;stroke:#cceb68;white-space:pre' transform='matrix(.51199 0 0 .5273 -46.467 211.966)' x='211.757' y='466.61'>", strLifetimePercent);

        parts[4] = "%</text><text style='fill:#dbfad4;font-family:Arial,sans-serif;font-size:64.6px;font-weight:700;stroke:#cceb68;white-space:pre;text-anchor:middle' transform='matrix(.51199 0 0 .5273 134.307 209.57)' x='211.757' y='466.61'>";

        parts[5] = string.concat(assetHeldSymbol, "</text>"); // Is concat cheaper than abi.encode ??
        
        parts[6] = string.concat(isInMoney ? ARROW_RIGHT_UP : ARROW_RIGHT_DOWN, "<text style='fill:#dbfad4;font-family:Arial,sans-serif;font-size:64.6px;font-weight:700;stroke:#cceb68;white-space:pre' transform='matrix(.51199 0 0 .5273 290.812 211.966)' x='211.757' y='466.61'>");

        parts[7] = string.concat(strSwapPercent, "%</text><path style='fill:#d8d8d8;stroke:#cceb68' transform='rotate(89.995 161.328 435.362)' d='m117.886 435.308 86.884.108'/><text style='fill:#f8ffbf;font-family:Arial,sans-serif;font-size:21px;font-weight:700;text-anchor:middle;white-space:pre' transform='translate(55.227 -10.244)'><tspan x='24.819' y='392.296'>LIFETIME OF</tspan><tspan x='24.819' dy='1em'></tspan></text><text style='fill:#f8ffbf;font-family:Arial,sans-serif;font-size:23px;font-weight:700;white-space:pre;text-anchor:middle' x='243.256' y='391.533'>ASSET</text><text style='fill:#f8ffbf;font-family:Arial,sans-serif;font-size:21px;font-weight:700;white-space:pre;text-anchor:middle' transform='translate(54.882 -18.474)'><tspan x='361.222' y='398.644'>SINCE LAST</tspan><tspan x='361.222' dy='1em'></tspan></text><path style='fill:#d8d8d8;stroke:#cceb68' transform='rotate(89.995 328.613 435.362)' d='m285.171 435.308 86.884.108'/><text style='fill:#f8ffbf;font-family:Arial,sans-serif;font-size:21px;font-weight:700;text-anchor:middle;white-space:pre' transform='translate(53.925 10.098)'><tspan x='24.819' y='392.296'>POSITION</tspan><tspan x='24.819' dy='1em'></tspan></text><text style='fill:#f8ffbf;font-family:Arial,sans-serif;font-size:21px;font-weight:700;white-space:pre;text-anchor:middle' transform='translate(54.882 1.839)'><tspan x='361.222' y='398.644'>SWAP</tspan><tspan x='361.222' dy='1em'></tspan></text></svg>");

        //return string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7]));
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