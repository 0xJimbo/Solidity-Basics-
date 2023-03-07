// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Escrow {
    address public depositor;
    address public beneficiary;
    address public arbiter;
    bool public isApproved;

    constructor (address _arbiter, address _depositor) payable {
        depositor = msg.sender;
        beneficiary = _depositor;
        arbiter = _arbiter;
    }

    function approve() external {
        require (msg.sender == arbiter, "You are not the arbiter");
        isApproved = true;
        uint amountSent = address(this).balance;
        (bool sent, ) = beneficiary.call{ value: amountSent
        }("");
        require(sent, "Failed to send ether");
        emit Approved(amountSent);
    }

    event Approved(uint balanceTransferred);


}