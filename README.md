# Contribution Tracker DApp

This project is a decentralized application (DApp) built on Ethereum that allows users to contribute Ether and tracks their contributions. The contract owner can distribute tokens proportionally based on the contributions.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Contract Overview](#contract-overview)
- [Frontend Overview](#frontend-overview)
- [Running the Project](#running-the-project)

## Prerequisites

Ensure you have the following installed:

- Node.js (version 14 or 16)
- npm (Node Package Manager)
- MetaMask extension for your browser
- Hardhat

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/contribution-tracker-dapp.git
    cd contribution-tracker-dapp
    ```

2. Install dependencies:
    ```bash
    npm install
    ```

3. Install Ganache CLI:
    ```bash
    npm install -g ganache-cli
    ```

## Usage

1. Start Ganache:
    ```bash
    ganache-cli
    ```

2. Compile the smart contract:
    ```bash
    npx hardhat compile
    ```

3. Deploy the smart contract:
    ```bash
    npx hardhat run scripts/deploy.js --network localhost
    ```

4. Note the deployed contract address and update the `.env` file:
    ```plaintext
    NEXT_PUBLIC_CONTRACT_ADDRESS=your_deployed_contract_address_here
    ```

5. Start the frontend:
    ```bash
    npm run dev
    ```

6. Open your browser and navigate to `http://localhost:3000`.

## Contract Overview

The smart contract `ContributionTracker.sol` includes the following features:

- **Mappings**:
  - `contributions`: Tracks Ether contributions from each address.
  - `tokenBalances`: Tracks token balances of each address.

- **State Variables**:
  - `owner`: The contract owner's address.
  - `totalContributions`: Total contributions received by the contract.
  - `totalTokens`: Total tokens distributed by the contract.

- **Events**:
  - `Contributed`: Emitted when a contribution is made.
  - `TokensDistributed`: Emitted when tokens are distributed.

- **Modifiers**:
  - `onlyOwner`: Restricts function access to the contract owner.

- **Constructor**:
  - Sets the deployer as the contract owner.

- **Functions**:
  - `contribute`: Allows users to send Ether to the contract, updating their contribution amount.
  - `distributeTokens`: Allows the owner to distribute tokens proportionally based on contributions.
  - `getContribution`: Returns the contribution amount for a specific address.
  - `getTokenBalance`: Returns the token balance for a specific address.

### Smart Contract Code

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ContributionTracker {
    mapping(address => uint) public contributions;
    mapping(address => uint) public tokenBalances;
    address public owner;
    uint public totalContributions;
    uint public totalTokens;

    event Contributed(address indexed contributor, uint amount);
    event TokensDistributed(uint totalTokens);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function contribute() public payable {
        require(msg.value > 0, "Contribution must be greater than zero");
        contributions[msg.sender] += msg.value;
        totalContributions += msg.value;
        emit Contributed(msg.sender, msg.value);
    }

    function distributeTokens(uint _totalTokens) public onlyOwner {
        require(totalContributions > 0, "No contributions to distribute tokens");
        totalTokens = _totalTokens;
        for (uint i = 0; i < address(this).balance; i++) {
            address contributor = address(uint160(i));
            uint contribution = contributions[contributor];
            uint tokens = (contribution * totalTokens) / totalContributions;
            tokenBalances[contributor] = tokens;
        }
        emit TokensDistributed(_totalTokens);
    }

    function getContribution(address contributor) public view returns (uint) {
        return contributions[contributor];
    }

    function getTokenBalance(address contributor) public view returns (uint) {
        return tokenBalances[contributor];
    }
}
