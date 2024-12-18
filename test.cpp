#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
#include <ctime>
#include <stdexcept>

class Voting {
public:
    struct Candidate {
        int id;
        std::string name;
        std::string party;
        int voteCount;

        Candidate(int id, const std::string& name, const std::string& party)
            : id(id), name(name), party(party), voteCount(0) {}
    };

private:
    std::unordered_map<int, Candidate> candidates;
    std::unordered_map<std::string, bool> voters;
    int countCandidates = 0;
    std::time_t votingStart = 0;
    std::time_t votingEnd = 0;

public:
    int addCandidate(const std::string& name, const std::string& party) {
        countCandidates++;
        candidates[countCandidates] = Candidate(countCandidates, name, party);
        return countCandidates;
    }

    void vote(const std::string& voterAddress, int candidateID) {
        std::time_t now = std::time(nullptr);

        if (!(votingStart <= now && now < votingEnd)) {
            throw std::runtime_error("Voting is not currently active.");
        }

        if (candidateID <= 0 || candidateID > countCandidates) {
            throw std::invalid_argument("Invalid candidate ID.");
        }

        if (voters[voterAddress]) {
            throw std::runtime_error("Voter has already voted.");
        }

        voters[voterAddress] = true;
        candidates[candidateID].voteCount++;
    }

    bool checkVote(const std::string& voterAddress) const {
        auto it = voters.find(voterAddress);
        return it != voters.end() && it->second;
    }

    int getCountCandidates() const {
        return countCandidates;
    }

    Candidate getCandidate(int candidateID) const {
        if (candidates.find(candidateID) == candidates.end()) {
            throw std::invalid_argument("Candidate does not exist.");
        }
        return candidates.at(candidateID);
    }

    void setDates(std::time_t startDate, std::time_t endDate) {
        std::time_t now = std::time(nullptr);

        if (votingStart != 0 || votingEnd != 0) {
            throw std::runtime_error("Voting dates are already set.");
        }

        if (startDate < now || endDate <= startDate) {
            throw std::invalid_argument("Invalid voting dates.");
        }

        votingStart = startDate;
        votingEnd = endDate;
    }

    std::pair<std::time_t, std::time_t> getDates() const {
        return {votingStart, votingEnd};
    }
};

int main() {
    Voting votingSystem;

    try {
        // Set voting dates
        std::time_t now = std::time(nullptr);
        votingSystem.setDates(now + 10, now + 1000);

        // Add candidates
        votingSystem.addCandidate("Alice", "Party A");
        votingSystem.addCandidate("Bob", "Party B");

        // Simulate voting
        std::this_thread::sleep_for(std::chrono::seconds(11)); // Wait for voting to start

        votingSystem.vote("voter1", 1);
        votingSystem.vote("voter2", 2);

        // Check votes
        std::cout << "Voter1 voted: " << votingSystem.checkVote("voter1") << "\n";
        std::cout << "Voter2 voted: " << votingSystem.checkVote("voter2") << "\n";

        // Print candidate details
        for (int i = 1; i <= votingSystem.getCountCandidates(); ++i) {
            Voting::Candidate candidate = votingSystem.getCandidate(i);
            std::cout << "Candidate " << candidate.id << ": "
                      << candidate.name << " (" << candidate.party << ") - "
                      << candidate.voteCount << " votes\n";
        }
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << "\n";
    }

    return 0;
}
