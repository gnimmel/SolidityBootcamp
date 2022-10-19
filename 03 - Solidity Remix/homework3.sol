pragma solidity 0.8.17;


contract BootcampContract {

    uint256 number;

    address owner;
    address constant BURN_ADDR = 0x000000000000000000000000000000000000dEaD;

    constructor() {
        owner = msg.sender;
    }

    function getAddress() public view returns (address) {
        if (msg.sender == owner) {
            return BURN_ADDR;
        } else {
            return owner;
        }
    }

    function store(uint256 num) public {
        number = num;
    }


    function retrieve() public view returns (uint256){
        return number;
    }
}