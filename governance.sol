// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Voting {
    enum VoteStates {Absent, Yes, No}

    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        bool executed;
        mapping (address => VoteStates) voteStates;
    }
    
    Proposal[] public proposals;
    address[] public allowedVotersList;
    uint votingThreshold = 10;

    event ProposalCreated(uint);
    event VoteCast(uint, address indexed);

    mapping(address => bool) allowedVote;

    constructor(address[] memory allowedVoters) {
        allowedVotersList = allowedVoters;
        allowedVotersList.push(msg.sender);
        for(uint i = 0; i < allowedVotersList.length; i++) {
            address voter = allowedVotersList[i];
            allowedVote[voter] = true;
        }
    }

    
    
    function newProposal(address _target, bytes calldata _data) external {
        require(allowedVote[msg.sender] == true, "Not authorised");
        emit ProposalCreated(proposals.length);
        Proposal storage proposal = proposals.push();
        proposal.target = _target;
        proposal.data = _data;
    }

    function castVote(uint _proposalId, bool _supports) external {
        require(allowedVote[msg.sender] == true, "Not authorised");
        Proposal storage proposal = proposals[_proposalId];

        // clear out previous vote 
        if(proposal.voteStates[msg.sender] == VoteStates.Yes) {
            proposal.yesCount--;
        }
        if(proposal.voteStates[msg.sender] == VoteStates.No) {
            proposal.noCount--;
        }

        // add new vote 
        if(_supports) {
            proposal.yesCount++;
        }
        else {
            proposal.noCount++;
        }

        // we're tracking whether or not someone has already voted 
        // and we're keeping track as well of what they voted
        proposal.voteStates[msg.sender] = _supports ? VoteStates.Yes : VoteStates.No;

        emit VoteCast(_proposalId, msg.sender);

        if(proposal.yesCount == votingThreshold && !proposal.executed) {
            (bool success, ) = proposal.target.call(proposal.data);
            // Check if the call was successful
            require(success, "Call failed");
            proposal.executed = true;
        }

    }


}



