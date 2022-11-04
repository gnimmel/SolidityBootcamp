// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract Constants {    // This as a seperate contract does NOT appear to effect gas
    uint8 public tradeFlag = 1;
    //uint256 public basicFlag = 0;
    uint8 public dividendFlag = 1;
}

contract GasContract is Ownable, Constants {
    bool public isReady = false;
    
    uint8 public paymentCounter; // WHY are you here?
    
    uint8 public tradePercent = 12;
    uint8 public tradeMode;
    uint256 public immutable totalSupply; // cannot be updated
    
    address[5] public administrators;
    address public contractOwner;

    mapping(address => uint256) public balances;
    mapping(address => Payment[]) public payments;
    mapping(address => uint256) public whitelist;
    
    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }
    PaymentType constant defaultPayment = PaymentType.Unknown;

    //History[] public paymentHistory; // when a payment was updated

    struct Payment {
        PaymentType paymentType;
        uint256 paymentID;
        bool adminUpdated;
        string recipientName; // max 8 characters
        address recipient;
        address admin; // administrators address
        uint256 amount;
    }
    /*
    struct History {
        uint256 lastUpdate;
        address updatedBy;
        uint256 blockNumber;
    }
    */
    bool wasLastOdd = true;

    mapping(address => bool) public isOddWhitelistUser;
    
    struct ImportantStruct { // changing A and B to uint8 actually increases gas usage
        uint256 valueA; // max 3 digits 
        uint256 bigValue;
        uint256 valueB; // max 3 digits
    }

    mapping(address => ImportantStruct) public whiteListStruct;

    event AddedToWhitelist(address userAddress, uint256 tier);

    function onlyAdminOrOwner() internal view {
        //address senderOfTx = msg.sender;
        if (!checkForAdmin(msg.sender) && (msg.sender != contractOwner))
            revert(
                "Caller not admin and not owner"
            );
        
        /*
        if (checkForAdmin(msg.sender)) {
            require(
                checkForAdmin(msg.sender),
                "Caller not admin"
            );
            _;
        } else if (msg.sender == contractOwner) {
            _;
        } else {
            revert(
                "Caller not admin and not owner"
            );
        }
        */
    }
    /*
    modifier checkIfWhiteListed(address sender) {
        //address senderOfTx = msg.sender;
        require(
            msg.sender == sender,
            "Originator was not the sender"
        );
        uint256 usersTier = whitelist[msg.sender];
        require(
            usersTier > 0,
            "User is not whitelisted"
        );
        require(
            usersTier < 4,
            "Tier must be < 4"
        );
        _;
    }
    */
    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        string recipient
    );
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) 
    {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < administrators.length; ii++) {
            address addr = _admins[ii];
            if (addr != address(0)) {
                administrators[ii] = addr;

                if (addr == contractOwner) {
                    balances[contractOwner] = _totalSupply;
                    emit supplyChanged(contractOwner, _totalSupply);
                } else {
                    balances[addr] = 0;
                    emit supplyChanged(addr, 0);
                }
            }
        }
    }

    /*function getPaymentHistory()
        public
        payable
        returns (History[] memory paymentHistory_)
    {
        return paymentHistory;
    }*/

    function checkForAdmin(address _user) internal view returns (bool admin_) {
        //bool admin = false;
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                return true;
            }
        }
        return false;
    }

    function balanceOf(address _user) external view returns (uint256 balance_) {
        return balances[_user];
    }

    function getTradingMode() external view returns (bool mode_) {
        if (tradeFlag == 1 || dividendFlag == 1)
            return true;
        else
            return false;
    }

    //function addHistory(address _updateAddress, bool _tradeMode) 
    /*
    function addHistory(address _updateAddress) 
        internal
        //returns (bool status_, bool tradeMode_)
    {
        History memory history;
        history.blockNumber = block.number;
        history.lastUpdate = block.timestamp;
        history.updatedBy = _updateAddress;
        paymentHistory.push(history);
        
        bool[] memory status = new bool[](tradePercent);
        for (uint256 i = 0; i < tradePercent; i++) {
            status[i] = true;
        }
        return ((status[0] == true), _tradeMode);
    }*/

    function getPayments(address _user)
        external
        view
        returns (Payment[] memory payments_)
    {
        require(
            _user != address(0),
            "Invalid address"
        );
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) external returns (bool status_) 
    {
        //address senderOfTx = msg.sender;
        require(
            balances[msg.sender] >= _amount,
            "Insufficient Balance"
        );
        require(
            bytes(_name).length < 9,
            "Name is too long"
        );
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        /*Payment memory payment;
        payment.admin = address(0);
        payment.adminUpdated = false;
        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = _name;
        payment.paymentID = ++paymentCounter;
        */
        payments[msg.sender].push(Payment({
            admin: address(0),
            adminUpdated: false,
            paymentType: PaymentType.BasicPayment,
            recipient: _recipient,
            amount: _amount,
            recipientName: _name,
            paymentID: ++paymentCounter
        }));
        
        bool[] memory status = new bool[](tradePercent); // What exactly is this doing?

        for (uint256 i = 0; i < tradePercent; i++) {
            status[i] = true;
        }
        return (status[0] == true);
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) external {
        onlyAdminOrOwner(); // Will revert on fail
        require(
            _ID > 0,
            "ID must be greater than 0"
        );
        require(
            _amount > 0,
            "Amount must be greater than 0"
        );
        require(
            _user != address(0),
            "Invalid address"
        );

        for (uint256 ii = 0; ii < payments[_user].length; ii++) {
            
            if (payments[_user][ii].paymentID == _ID) 
            {
                payments[_user][ii].adminUpdated = true;
                payments[_user][ii].admin = _user;
                payments[_user][ii].paymentType = _type;
                payments[_user][ii].amount = _amount;
                //bool tradingMode = getTradingMode();
                //addHistory(_user, tradingMode);
                //addHistory(_user);

                emit PaymentUpdated(
                    msg.sender,
                    _ID,
                    _amount,
                    payments[_user][ii].recipientName
                );
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        external
        //onlyAdminOrOwner
    {
        onlyAdminOrOwner();
        require(
            _tier < 255,
            "Tier must be < 255"
        );

        whitelist[_userAddrs] = _tier > 3 ? 3 : _tier;
        
        /*
        // This logical is janky af 
        if (_tier > 3) {
            whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = 3;
        } else if (_tier == 1) {
            whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = 1;
        } else if (_tier > 0 && _tier < 3) {
            whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = 2;
        }*/

        wasLastOdd = !wasLastOdd;
        isOddWhitelistUser[_userAddrs] = wasLastOdd; // Why are we tracking odds? It's not tested... so remove it?
        
        /*
        uint256 wasLastAddedOdd = wasLastOdd;
        
        if (wasLastAddedOdd == 1) {
            wasLastOdd = 0;
            isOddWhitelistUser[_userAddrs] = wasLastAddedOdd;
        } else if (wasLastAddedOdd == 0) {
            wasLastOdd = 1;
            isOddWhitelistUser[_userAddrs] = wasLastAddedOdd;
        } else {
            revert("Contract hacked, call help");
        }
        */
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        ImportantStruct memory _struct
    ) external 
    {
        require(
            whitelist[msg.sender] > 0,
            "User is not whitelisted"
        );
        require(
            balances[msg.sender] >= _amount,
            "Insufficient Balance"
        );
        require(
            _amount > 3,
            "Amount must be > 3"
        );
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[msg.sender] += whitelist[msg.sender]; // WHY is the whitelist tier value added to the user balance?
        balances[_recipient] -= whitelist[msg.sender]; 

        whiteListStruct[msg.sender] = ImportantStruct(0, 0, 0);
        ImportantStruct storage newImportantStruct = whiteListStruct[
            msg.sender
        ];
        newImportantStruct.valueA = _struct.valueA;
        newImportantStruct.bigValue = _struct.bigValue;
        newImportantStruct.valueB = _struct.valueB;
        emit WhiteListTransfer(_recipient);
    }
}
