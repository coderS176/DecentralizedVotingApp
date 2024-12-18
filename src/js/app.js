//import "../css/style.css"

const Web3 = require('web3');
const contract = require('@truffle/contract');

const votingArtifacts = require('../../build/contracts/Voting.json');
var VotingContract = contract(votingArtifacts)

window.App = {
  eventStart: function() {
    // Request MetaMask account access
    window.ethereum.request({ method: 'eth_requestAccounts' }).then((accounts) => {
      if (!accounts || accounts.length === 0) {
        console.error("No accounts found. Please connect MetaMask.");
        alert("No accounts found. Please connect MetaMask.");
        return;
      }

      App.account = accounts[0];
      console.log("Connected account:", App.account);
      $("#accountAddress").html("Your Account: " + App.account);

      VotingContract.setProvider(window.ethereum);
      VotingContract.defaults({ from: App.account, gas: 6654755 });

      VotingContract.deployed().then(function (instance) {
        console.log("Contract deployed at:", instance.address);

        instance.getCountCandidates().then(function (countCandidates) {
          console.log("Number of candidates:", countCandidates);

          $(document).ready(function () {
            $('#addCandidate').click(function () {
              var nameCandidate = $('#name').val();
              var partyCandidate = $('#party').val();
              if (!nameCandidate || !partyCandidate) {
                console.error("Candidate name or party is missing.");
                alert("Please fill in both name and party fields.");
                return;
              }

              instance.addCandidate(nameCandidate, partyCandidate, { from: App.account })
                .then(function (result) {
                  console.log("Candidate added successfully:", result);
                })
                .catch(function (err) {
                  console.error("Error adding candidate:", err.message);
                });
            });

            $('#addDate').click(function () {
              var startDate = Date.parse(document.getElementById("startDate").value) / 1000;
              var endDate = Date.parse(document.getElementById("endDate").value) / 1000;
              if (!startDate || !endDate) {
                console.error("Start or end date is missing or invalid.");
                alert("Please provide valid start and end dates.");
                return;
              }

              instance.setDates(startDate, endDate, { from: App.account })
                .then(function (result) {
                  console.log("Dates set successfully:", result);
                })
                .catch(function (err) {
                  console.error("Error setting dates:", err.message);
                });
            });

            instance.getDates().then(function (result) {
              var startDate = new Date(result[0] * 1000);
              var endDate = new Date(result[1] * 1000);

              $("#dates").text(startDate.toDateString() + " - " + endDate.toDateString());
            }).catch(function (err) {
              console.error("Error fetching dates:", err.message);
            });
          });

          for (var i = 0; i < countCandidates; i++) {
            instance.getCandidate(i + 1).then(function (data) {
              var id = data[0];
              var name = data[1];
              var party = data[2];
              var voteCount = data[3];
              console.log(`Candidate ${id}: ${name} (${party}) - ${voteCount} votes`);

              var viewCandidates = `<tr><td><input class="form-check-input" type="radio" name="candidate" value="${id}" id=${id}>` + name + "</td><td>" + party + "</td><td>" + voteCount + "</td></tr>";
              $("#boxCandidate").append(viewCandidates);
            }).catch(function (err) {
              console.error("Error fetching candidate:", err.message);
            });
          }
        }).catch(function (err) {
          console.error("Error fetching count of candidates:", err.message);
        });

        instance.checkVote().then(function (voted) {
          console.log("Has user voted?", voted);
          if (!voted) {
            $("#voteButton").attr("disabled", false);
          }
        }).catch(function (err) {
          console.error("Error checking vote status:", err.message);
        });
      }).catch(function (err) {
        console.error("Error deploying contract:", err.message);
      });
    }).catch((err) => {
      console.error("MetaMask connection error:", err.message);
      alert("MetaMask connection error. Please try again.");
    });
  },

  vote: function () {
    var candidateID = $("input[name='candidate']:checked").val();
    if (!candidateID) {
      $("#msg").html("<p>Please vote for a candidate.</p>");
      console.error("No candidate selected.");
      return;
    }

    VotingContract.deployed().then(function (instance) {
      instance.vote(parseInt(candidateID), { from: App.account })
        .then(function (result) {
          console.log("Vote cast successfully:", result);
          $("#voteButton").attr("disabled", true);
          $("#msg").html("<p>Voted</p>");
          window.location.reload(1);
        }).catch(function (err) {
          console.error("Error casting vote:", err.message);
        });
    }).catch(function (err) {
      console.error("Error accessing contract for voting:", err.message);
    });
  }
};

window.addEventListener("load", function () {
  if (typeof web3 !== "undefined") {
    console.warn("Using web3 detected from external source like MetaMask");
    window.eth = new Web3(window.ethereum);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:9545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to MetaMask for deployment. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    window.eth = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:9545"));
  }
  window.App.eventStart();
});
