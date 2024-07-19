// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ContributionTracker {
    // Mapping to track contributions from each address
    mapping(address => uint) public contributions;
    // Mapping to track token balances of each address
    mapping(address => uint) public tokenBalances;
    // Address of the contract owner
    address public owner;
    // Total contributions received by the contract
    uint public totalContributions;
    // Total tokens distributed by the contract
    uint public totalTokens;

    // Event emitted when a contribution is made
    event Contributed(address indexed contributor, uint amount);
    // Event emitted when tokens are distributed
    event TokensDistributed(uint totalTokens);

    // Modifier to restrict access to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Constructor to set the contract owner to the deployer
    constructor() {
        owner = msg.sender;
    }

    // Function to allow users to contribute Ether to the contract
    function contribute() public payable {
        // Require that the contribution is greater than zero
        require(msg.value > 0, "Contribution must be greater than zero");
        // Increment the contributions mapping for the sender's address
        contributions[msg.sender] += msg.value;
        // Increment the total contributions
        totalContributions += msg.value;
        // Emit the Contributed event
        emit Contributed(msg.sender, msg.value);
    }

    // Function to distribute tokens based on contributions
    // Only the contract owner can call this function
    function distributeTokens(uint _totalTokens) public onlyOwner {
        // Require that there have been contributions
        require(totalContributions > 0, "No contributions to distribute tokens");
        // Set the total tokens to be distributed
        totalTokens = _totalTokens;
        // Loop through each address that contributed (not optimal for large datasets)
        for (uint i = 0; i < address(this).balance; i++) {
            address contributor = address(uint160(i));
            uint contribution = contributions[contributor];
            uint tokens = (contribution * totalTokens) / totalContributions;
            tokenBalances[contributor] = tokens;
        }
        // Emit the TokensDistributed event
        emit TokensDistributed(_totalTokens);
    }

    // Function to get the contribution amount for a given address
    function getContribution(address contributor) public view returns (uint) {
        return contributions[contributor];
    }

    // Function to get the token balance for a given address
    function getTokenBalance(address contributor) public view returns (uint) {
        return tokenBalances[contributor];
    }
}