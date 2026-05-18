// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleVote{

    // ------------------ //
    // DATA STRUCTURES
    // ----------------- //
    struct Candidate{
        string name;
        uint voteCount;
    }
    struct Voter{
        bool hasVoted;
        uint age;
    }

    // --------------- //
    // STATE VARIABLES
    //----------------//

    Candidate[] public candidates;

    mapping(address => Voter) public voters;

    address public owner;

    // Voting window
    uint public votingStart;
    uint public votingEnd;
    bool public votingActive;

     // Minimum age to vote
    uint public constant MINIMUM_AGE = 18;

    // ------------//
    // EVENTS
    // ----------//
   event CandidateAdded(string name);
   event VotingStarted(uint startTime, uint endTime);
   event VoteCast(address indexed voter, uint candidateIndex);
   event VotingStopped(uint timeStamp);

   // ----------------//
   // CONSTRUCTOR
   //-----------------//
   constructor(){
    owner = msg.sender;
    votingActive = false;
   }

   // ----------------//
   // MODIFIERS
   //----------------//
   // Only owner can call this function
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    // Voting must be currently active
    modifier votingIsActive() {
        require(votingActive, "Voting is not active");
        require(block.timestamp >= votingStart, "Voting has not started yet");
        require(block.timestamp <= votingEnd, "Voting period has ended");
        _;
    }

    // ----------------//
    // OWNER FUNCTIONS
    //-----------------//

    // Add a candidate — only before voting starts
    function addCandidate(string memory name) public onlyOwner{
        require(!votingActive, "Cannot add candidates while voting is active");
        candidates.push(Candidate(name,0));
        emit CandidateAdded(name);
    }

    // Start voting with a duration in minutes

    function startVoting(uint durationInMinutes) public onlyOwner{
        require(!votingActive, "Voting has already started");
        require(candidates.length > 1, "Add atleast 2 candidates first ");
        require(durationInMinutes > 0, "Duration must be greater than zero");

        votingStart = block.timestamp;
        votingEnd = block.timestamp + (durationInMinutes * 1 minutes);
        votingActive = true;
        emit VotingStarted(votingStart,  votingEnd);
    }

    // Stop Voting early if needed
    function stopVotin() public onlyOwner{
        require(votingActive, "Voting is not active");
        votingActive = false;
        emit VotingStopped(block.timestamp);
    }

    // ---------------- //
    // VOTER FUNCTIONS
    // --------------- //
    // Register as a voter with your age
    function registerVoter(uint age) public{
        require(age>= MINIMUM_AGE, "You must be atleast 18 years old to vote");
        require(voters[msg.sender].age==0, "You are already registered");
        voters[msg.sender] = Voter(false, age);
    }


    // Caste a Vote -
    // Note - we are using index numbers of candidates due to scope of the workshop
    function castAVote(uint candidateIndex) public votingIsActive{

        Voter storage voter = voters[msg.sender];
        require(voter.age >= MINIMUM_AGE, "You must be registered and at least 18 to vote");
        require(!voter.hasVoted, "You have already voted");
        require(candidateIndex < candidates.length, "Invalid candidate");
        candidates[candidateIndex].voteCount += 1;
        voter.hasVoted = true;

        emit VoteCast(msg.sender, candidateIndex);

    }

    // ----------------//
    // VIEW FUNCTION
    //-----------------//
    // Get results for a specific candidate
    function getResults(uint candidateIndex) public view returns(string memory name, uint voteCount){

        require(candidateIndex < candidates.length, "Invalid candidate");
        Candidate memory c = candidates[candidateIndex];
        return (c.name, c.voteCount);
    }

    // Get total number of candidates
    function getCandidateCount() public view returns (uint) {
        return candidates.length;
    }

    // Get time remaining in seconds
    function getTimeRemaining() public view returns (uint) {
        if (!votingActive || block.timestamp > votingEnd) {
            return 0;
        }
        return votingEnd - block.timestamp;
    }

    // check if the voting window is currently open
    function isVotingOpen() view public returns (bool){
        return votingActive &&
        block.timestamp >= votingStart &&
        block.timestamp <=votingEnd;
    }




    //---------------- //
    // HELPER FUNCTIONS
    // -------------- //









}