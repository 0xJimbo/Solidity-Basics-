// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {

    address[] public owners;
    uint256 public required;
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint256 weiValue;
        bool executed;
        bytes data;
    }

    receive() payable external {}

    constructor(address[] memory ownerAddys, uint requiredConfirmations) {
        require(ownerAddys.length > 0, "No owners provided");
        require(requiredConfirmations > 0, "Confirmations required must be more than 0");
        require(ownerAddys.length > requiredConfirmations, "Needs to be more owners than confirmations required");
        owners = ownerAddys;
        required = requiredConfirmations;
    }

    mapping(uint => Transaction) public transactions;
    

    function submitTransaction(address destination, uint value, bytes memory _data) external {
        confirmTransaction(addTransaction(destination, value, _data));
    }

    function addTransaction(address destination, uint256 value, bytes memory _data) internal returns(uint transactionID) {
        transactionID = transactionCount;
        transactions[transactionCount] = Transaction(destination, value, false, _data);
        transactionCount += 1;
    }
    
    mapping(uint => mapping(address => bool)) public confirmations;

    function confirmTransaction(uint transactionID) public {
    require(isOwner(msg.sender), "msg.sender must be an owner");
    confirmations[transactionID][msg.sender] = true;
    if(isConfirmed(transactionID)) {
        executeTransaction(transactionID);
    }
    }

function isOwner(address addr) private view returns (bool) {
    for (uint i = 0; i < owners.length; i++) {
        if (owners[i] == addr) {
            return true;
        }
    }
    return false;
    }

    function getConfirmationsCount(uint transactionID) public view returns (uint confirmationsCount) {
    confirmationsCount = 0;
    for (uint i = 0; i < owners.length; i++) {
        if (confirmations[transactionID][owners[i]]) {
            confirmationsCount += 1;
            }
        }
    }

    function isConfirmed(uint transactionId) public view returns(bool) {
        return getConfirmationsCount(transactionId) >= required;
    }

    function executeTransaction(uint transactionID) public {
        Transaction storage transaction = transactions[transactionID];
        address recipient = transaction.destination;
        uint256 value = transaction.weiValue;
        require(isConfirmed(transactionID), "Transaction not confirmed");
        (bool sent, ) = recipient.call{value: value}(transaction.data);
        require(sent, "Failed to send");
        transaction.executed = true;
    }

    // Transaction[] public transactions;

    // function transactionCount() public view returns(uint) {
    //     return transactions.length;
    // }

}
