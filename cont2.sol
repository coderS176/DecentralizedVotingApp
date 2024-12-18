// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlockchainVoting {
    // Roles
    address public admin;
    enum ElectionState { NotStarted, Ongoing, Ended }
    ElectionState public electionState;

    // Voter struct
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        address delegate;
        uint256 votedFor;
    }

    // Candidate struct
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    // Mappings
    mapping(address => Voter) public voters;
    mapping(uint256 => Candidate) public candidates;
    uint256 public candidateCount;

    // Events
    event ElectionStarted();
    event ElectionEnded();
    event VoterRegistered(address voter);
    event CandidateRegistered(uint256 id, string name);
    event VoteCasted(address voter, uint256 candidateId);
    event RightDelegated(address from, address to);

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier electionOngoing() {
        require(electionState == ElectionState.Ongoing, "Election is not ongoing.");
        _;
    }

    modifier electionNotStarted() {
        require(electionState == ElectionState.NotStarted, "Election has already started.");
        _;
    }

    modifier electionEnded() {
        require(electionState == ElectionState.Ended, "Election is not ended yet.");
        _;
    }

    constructor() {
        admin = msg.sender;
        electionState = ElectionState.NotStarted;
    }

    // Admin functions
    function startElection() public onlyAdmin electionNotStarted {
        electionState = ElectionState.Ongoing;
        emit ElectionStarted();
    }

    function endElection() public onlyAdmin {
        require(electionState == ElectionState.Ongoing, "Election is not ongoing.");
        electionState = ElectionState.Ended;
        emit ElectionEnded();
    }

    function showResults() public view electionEnded returns (Candidate[] memory) {
        Candidate[] memory resultList = new Candidate[](candidateCount);
        for (uint256 i = 1; i <= candidateCount; i++) {
            resultList[i - 1] = candidates[i];
        }
        return resultList;
    }

    // Voter functions
    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter is already registered.");
        voters[_voter] = Voter({ isRegistered: true, hasVoted: false, delegate: address(0), votedFor: 0 });
        emit VoterRegistered(_voter);
    }

    function vote(uint256 _candidateId) public electionOngoing {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "You are not a registered voter.");
        require(!sender.hasVoted, "You have already voted.");
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID.");

        sender.hasVoted = true;
        sender.votedFor = _candidateId;
        candidates[_candidateId].voteCount++;
        emit VoteCasted(msg.sender, _candidateId);
    }

    function delegateVote(address _to) public electionOngoing {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "You are not a registered voter.");
        require(!sender.hasVoted, "You have already voted.");
        require(_to != msg.sender, "Self-delegation is not allowed.");

        while (voters[_to].delegate != address(0)) {
            _to = voters[_to].delegate;
            require(_to != msg.sender, "Found a loop in delegation.");
        }

        sender.hasVoted = true;
        sender.delegate = _to;
        Voter storage delegate_ = voters[_to];
        if (delegate_.hasVoted) {
            candidates[delegate_.votedFor].voteCount++;
        }
        emit RightDelegated(msg.sender, _to);
    }

    function viewVoterDetails(address _voter) public view returns (bool, bool, address, uint256) {
        Voter memory voter = voters[_voter];
        return (voter.isRegistered, voter.hasVoted, voter.delegate, voter.votedFor);
    }

    // Candidate functions
    function registerCandidate(string memory _name) public onlyAdmin {
        candidateCount++;
        candidates[candidateCount] = Candidate({ id: candidateCount, name: _name, voteCount: 0 });
        emit CandidateRegistered(candidateCount, _name);
    }

    function viewCandidates() public view returns (Candidate[] memory) {
        Candidate[] memory candidateList = new Candidate[](candidateCount);
        for (uint256 i = 1; i <= candidateCount; i++) {
            candidateList[i - 1] = candidates[i];
        }
        return candidateList;
    }

    function viewCandidateDetails(uint256 _id) public view returns (uint256, string memory, uint256) {
        require(_id > 0 && _id <= candidateCount, "Invalid candidate ID.");
        Candidate memory candidate = candidates[_id];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
}


// what we are doing in this code I know C++ very well reference that
// we are creating a contract for voting system
// we have 3 roles in this contract
// 1. admin
// 2. voter
// 3. candidate
// we have 3 states in this contract
// 1. NotStarted
// 2. Ongoing
// 3. Ended

// we have 2 structs in this contract
// 1. Voter
// 2. Candidate

// we have 3 mappings in this contract
// 1. voters
// 2. candidates
// 3. candidateCount

// we have 5 events in this contract
// 1. ElectionStarted
// 2. ElectionEnded
// 3. VoterRegistered
// 4. CandidateRegistered
// 5. VoteCasted

// we have 3 modifiers in this contract
// 1. onlyAdmin
// 2. electionOngoing
// 3. electionNotStarted

// we have 10 functions in this contract
// 1. startElection
// 2. endElection
// 3. showResults
// 4. registerVoter
// 5. vote
// 6. delegateVote
// 7. viewVoterDetails
// 8. registerCandidate
// 9. viewCandidates
// 10. viewCandidateDetails

// we have 1 constructor in this contract
// 1. constructor

// we have 1 state variable in this contract
// 1. electionState

// we have 1 address variable in this contract
// 1. admin

// we have 1 uint256 variable in this contract
// 1. candidateCount

// we have 2 enums in this contract
// 1. ElectionState
