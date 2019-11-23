/*
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    election.sol                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: imaltsev <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2019/11/23 20:39:44 by imaltsev          #+#    #+#              #
#    Updated: 2019/11/23 20:39:46 by imaltsev         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #
*/
pragma solidity 0.5.13;

/*
This contract necessary for contracts that have Ownable logic.
*/

contract Ownable{
    address public owner;
    
    modifier OnlyOwner(){
        require(msg.sender==owner);
        _;
    }
    
    constructor() public{
        owner = msg.sender;
    }
}

/*
The first smart contract (Passport) is a program for storing data about users, something like a passport.
The contract must store the user data (such as Name, Surname, age, personal hash or user id)
and have the functionality to record new users. These
data must be public for other contracts. It is allowed to expand the list of user
parameters if you think that it is necessary.
*/

contract Passport is Ownable{
    
    mapping(uint=>User) public users;
    uint public userCounter;

    struct User{
        string  _name;
        string  _surname;
        uint    _age;
        address _addr;
    }
    
    function record(string memory _name, string memory _surname, uint _age, address _addr) public OnlyOwner{
        userCounter += 1;
        users[userCounter] = User(_name, _surname, _age, _addr);
    }
    
    function isAddressInStore(address _addr) public view  returns(bool){
        for (uint i=1; i<userCounter+1; i++)
          if (users[i]._addr == _addr)
              return true;
        return false;
    }
    
    function killContract() public OnlyOwner{
        selfdestruct(msg.sender);
    }
    
}

/*
The second smart contract (Election) is a voting program. Users who were registered
in the first smart contract and only them, can take part in the voting, and after
the end of voting to know who won. One user can vote only for one candidate.
The contract must also contain the functionality available only to the owner of the
contract.
Such as:
◦ Adding a new candidate for voting
◦ Termination of voting
*/

contract Election is Ownable{
    Passport userStore;
    mapping(uint=>Candidate) public candidates;
    uint public candidatesCounter;
    ElectionStatus status;
    mapping(address=>bool) voters;
    uint public totalVotes;
    Passport passport;
    Candidate winner;
    
    enum ElectionStatus { HOLD, ACTIVE, END }
    
    struct Candidate{
        uint _id;
        bool _active;
        string _name;
        uint _voteCounter;
    }
    
    modifier OnlyForInPassport(){
        require(passport.isAddressInStore(msg.sender));
        _;
    }
    
    constructor(address _passportAddress) public{
        passport = Passport(_passportAddress);
        status = ElectionStatus.HOLD;
        candidatesCounter = 0;
        totalVotes = 0;
    }
    
    function changeElectionStatus(ElectionStatus _status) internal {
        status = _status;
    }
    
    function startElection() public OnlyOwner{
        changeElectionStatus(ElectionStatus.ACTIVE);
    }
    
    function endElection() public OnlyOwner{
        changeElectionStatus(ElectionStatus.END);
        Candidate memory maxVotesCandidate;
        for (uint i=1; i<candidatesCounter+1; i++){
            if (candidates[i]._voteCounter > maxVotesCandidate._voteCounter)
                maxVotesCandidate = candidates[i];
        }
        uint winnerCouner = 0;
        for (uint i=1; i<candidatesCounter+1; i++){
            if (candidates[i]._voteCounter == maxVotesCandidate._voteCounter)
                winnerCouner+=1;
        }
        
        if (winnerCouner==1){
            winner = maxVotesCandidate;
        }
        else{
            winner = Candidate(0, false, "draw", 0);
        }
    }
    
    function getElectionStatus() public view returns(string memory){
        if (status == ElectionStatus.HOLD){
            return "Owner has not start election yet. Please wait.";
        }
        else if (status == ElectionStatus.ACTIVE){
            return "Election is active. You can vote!";
        }
        else if (status == ElectionStatus.END){
            return "Election is end. You can check winner.";
        }
    }
    
    function checkPass(address _addr) internal view returns(bool){
        return passport.isAddressInStore(_addr);
    }
    
    function addCandidate(string memory _name) public OnlyOwner{
        require(status != ElectionStatus.END);
        incrementCandidateCounter();
        candidates[candidatesCounter] = Candidate(candidatesCounter, true, _name, 0);
    }
    
    function incrementCandidateCounter() internal{
        candidatesCounter += 1;
    }
    
    function vote(uint _id) public OnlyForInPassport{
        require(status == ElectionStatus.ACTIVE);
        require(checkPass(msg.sender));
        require(!voters[msg.sender]);
        require(candidates[_id]._active);
        voters[msg.sender] = true;
        candidates[_id]._voteCounter += 1;
        totalVotes+=1;
    }
    
    function getWinner() public view OnlyForInPassport returns (string memory, uint){
        require(status == ElectionStatus.END);
        return (winner._name, winner._voteCounter);
    }
    
    function killContract() public OnlyOwner{
        selfdestruct(msg.sender);
    }
}
