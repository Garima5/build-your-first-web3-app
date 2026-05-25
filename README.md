# build-your-first-web3-app
Lab for Toronto Tech Week Workshop - Build your first Web3 app

# 🗳️ SimpleVote — Build & Deploy Your First On-Chain App

> A hands-on Web3 workshop built for Toronto Tech Week 2026
> Hosted by **Garima** · [Deep Tech Studios](https://deepteching.com) · 🧁 Tiramisoo Community

---

## 📋 Table of Contents

1. [What We're Building](#what-were-building)
2. [Prerequisites](#prerequisites)
3. [Web3 Concepts You Need to Know](#web3-concepts-you-need-to-know)
4. [Understanding the Contract](#understanding-the-contract)
5. [Step 1 — Set Up MetaMask](#step-1--set-up-metamask)
6. [Step 2 — Get Sepolia Test ETH](#step-2--get-sepolia-test-eth)
7. [Step 3 — Open Remix IDE](#step-3--open-remix-ide)
8. [Step 4 — Compile the Contract](#step-4--compile-the-contract)
9. [Step 5 — Deploy on Remix VM (Local Test)](#step-5--deploy-on-remix-vm-local-test)
10. [Step 6 — Deploy to Sepolia Testnet](#step-6--deploy-to-sepolia-testnet)
11. [Step 7 — Vote on the Workshop Contract](#step-7--vote-on-the-workshop-contract)
12. [Step 8 — View Results on Etherscan](#step-8--view-results-on-etherscan)
13. [Contract Reference](#contract-reference)
14. [Troubleshooting](#troubleshooting)
15. [What's Next](#whats-next)

---

## What We're Building

A **decentralized voting application** — a smart contract that allows:

- An owner to add candidates and control the voting window
- Anyone to register as a voter (must be 18+)
- Registered voters to cast one vote each
- Anyone to read the results at any time — for free
- Everything recorded permanently and transparently on the Ethereum blockchain

**Why voting?** Because it perfectly demonstrates what makes Web3 powerful. No central authority counts the votes. No one can fake a result. No one can vote twice. The rules are enforced by code — not by a company, not by a government, not by trust.

---

## Prerequisites

Before starting you need:

- A laptop (not a tablet or phone)
- Chrome or Firefox browser (not Safari)
- MetaMask browser extension installed — [metamask.io](https://metamask.io)
- A small amount of Sepolia test ETH (free — instructions below)

> ⚠️ **Important:** You will NOT need to purchase any real cryptocurrency at any point. We use Sepolia Testnet ETH only — this has zero real monetary value. If anything asks you to buy real ETH or connect a bank account — stop immediately.

---

## Web3 Concepts You Need to Know

### 🔗 What is a Blockchain?
A blockchain is a database that nobody owns and nobody can change. Think of a chalkboard in a café that keeps a record of every order ever made. Every customer can see it. Nobody can erase a past order. The café doesn't own the chalkboard — the whole neighbourhood does. Once something is written on a blockchain — it's there forever.

### ⚡ What is Ethereum?
Ethereum is a blockchain with a superpower — it doesn't just store transactions, it can store and run code. Think of Bitcoin as a calculator (does one thing — sends money). Ethereum is more like a computer — you can run any program on it.

### 📜 What is a Smart Contract?
A smart contract is a program that lives on the blockchain and runs automatically when conditions are met. Like a vending machine — you put in money, press a button, get your item. No human in the middle. No trust required. Smart contracts are:
- **Automatic** — execute themselves when conditions are met
- **Trustless** — the code enforces the rules, no middleman needed
- **Unstoppable** — once deployed, nobody can shut them down

### 🌐 What is Web3?
Web3 is the next version of the internet where applications run on blockchains instead of company servers. In Web2 — Uber owns the platform, Facebook owns your data. In Web3 — nobody owns the platform. The code runs on a blockchain that belongs to everyone.

### 👛 What is a Wallet?
A crypto wallet is your identity on the blockchain. Every wallet has:
- **Public key / Address** — like your email address, you share it with everyone. Looks like `0x1234...abcd`
- **Private key** — like your password, except if you lose it nobody can reset it. NEVER share this.
- **Seed phrase** — 12 words that represent your wallet. Anyone with these words owns your wallet. Write it down offline. Never type it into any website.

### 🦊 What is MetaMask?
MetaMask is a browser extension that manages your wallet. Think of it as your Web3 passport — it keeps your keys safe and lets you interact with applications on the blockchain.

### 🧪 What is a Testnet?
Ethereum has multiple networks. **Mainnet** is the real one — real ETH, real money. **Testnets** are practice networks — same technology, fake money, zero consequences. We use **Sepolia testnet** today. Everything is identical to mainnet except the ETH has no value.

### ⛽ What is Gas?
Gas is the fee you pay the Ethereum network for doing computational work. Reading data is always free. Writing data (transactions) costs a tiny amount of gas. On Sepolia testnet — gas costs fake ETH so it's completely free.

### 🔍 What is Etherscan?
Etherscan is a blockchain explorer — a website where you can see every transaction ever made. We use [sepolia.etherscan.io](https://sepolia.etherscan.io) today to watch votes appear in real time.

### ⚙️ What is the EVM?
The Ethereum Virtual Machine is the engine that runs smart contracts. Every computer in the Ethereum network runs the same EVM — which means your contract executes identically on thousands of machines simultaneously. Nobody can manipulate the execution.

### 📋 What is an ABI?
The ABI (Application Binary Interface) is a list of all the functions in your contract and what inputs they accept. Think of it as your contract's menu — it tells Remix what buttons to show you. When you compile your contract, Remix automatically generates the ABI.

---

## Understanding the Contract

Here is the complete SimpleVote contract with explanations:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleVote {

    // ─── DATA STRUCTURES ───────────────────────────────────────────

    // A struct is like a box that holds related information together
    // Think of it like a form — a candidate form has a name and vote count
    struct Candidate {
        string name;
        uint voteCount;
    }

    // A voter has two properties — have they voted, and how old are they
    struct Voter {
        bool hasVoted;
        uint age;
    }

    // ─── STATE VARIABLES ───────────────────────────────────────────

    // State variables are stored permanently on the blockchain
    // Think of them like columns in a spreadsheet that lives on-chain forever

    Candidate[] public candidates;              // List of all candidates
    mapping(address => Voter) public voters;    // Lookup table: wallet address → voter info
    address public owner;                       // Wallet address of whoever deployed this contract
    uint public votingStart;                    // When voting begins (Unix timestamp)
    uint public votingEnd;                      // When voting ends (Unix timestamp)
    bool public votingActive;                   // Is voting currently on or off?
    uint public constant MINIMUM_AGE = 18;      // Nobody under 18 can vote — ever

    // ─── EVENTS ────────────────────────────────────────────────────

    // Events are like public notice boards — they broadcast when something happens
    // They show up as transaction logs on Etherscan
    event VoteCast(address indexed voter, uint candidateIndex);
    event VotingStarted(uint startTime, uint endTime);
    event VotingStopped(uint timeStamp);
    event CandidateAdded(string name);

    // ─── CONSTRUCTOR ───────────────────────────────────────────────

    // The constructor runs exactly once — when the contract is deployed
    // It sets the deployer as the owner
    constructor() {
        owner = msg.sender;     // msg.sender = the wallet address calling this right now
        votingActive = false;   // Voting is off by default
    }

    // ─── MODIFIERS ─────────────────────────────────────────────────

    // Modifiers are reusable rules — like a bouncer that checks everyone at the door
    // The _; means "now run the actual function"

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier votingIsActive() {
        require(votingActive, "Voting is not active");
        require(block.timestamp >= votingStart, "Voting has not started yet");
        require(block.timestamp <= votingEnd, "Voting period has ended");
        _;
    }

    // ─── OWNER FUNCTIONS ───────────────────────────────────────────

    // Add a candidate — only owner, only before voting starts
    function addCandidate(string memory name) public onlyOwner {
        require(!votingActive, "Cannot add candidates while voting is active");
        candidates.push(Candidate(name, 0));
        emit CandidateAdded(name);
    }

    // Start voting with a duration in minutes
    // block.timestamp = current time on the blockchain in Unix seconds
    function startVoting(uint durationInMinutes) public onlyOwner {
        require(!votingActive, "Voting is already active");
        require(candidates.length > 0, "Add at least one candidate first");
        require(durationInMinutes > 0, "Duration must be greater than zero");

        votingStart = block.timestamp;
        votingEnd = block.timestamp + (durationInMinutes * 1 minutes);
        votingActive = true;

        emit VotingStarted(votingStart, votingEnd);
    }

    // Stop voting early — owner only emergency stop
    function stopVoting() public onlyOwner {
        require(votingActive, "Voting is not active");
        votingActive = false;
        emit VotingStopped(block.timestamp);
    }

    // ─── VOTER FUNCTIONS ───────────────────────────────────────────

    // Register as a voter — anyone can call this
    // voters[msg.sender].age == 0 means never registered (default value)
    function registerVoter(uint age) public {
        require(age >= MINIMUM_AGE, "You must be at least 18 years old to vote");
        require(voters[msg.sender].age == 0, "You are already registered");
        voters[msg.sender] = Voter(false, age);
    }

    // Cast a vote — must be registered, 18+, not voted yet, valid candidate
    function castAVote(uint candidateIndex) public votingIsActive {
        Voter storage voter = voters[msg.sender];

        require(voter.age >= MINIMUM_AGE, "You must be registered and at least 18 to vote");
        require(!voter.hasVoted, "You have already voted");
        require(candidateIndex < candidates.length, "Invalid candidate");

        candidates[candidateIndex].voteCount += 1;
        voter.hasVoted = true;

        emit VoteCast(msg.sender, candidateIndex);
    }

    // ─── VIEW FUNCTIONS ────────────────────────────────────────────
    // View functions only READ data — they are always FREE to call
    // MetaMask will NEVER pop up when you call these

    // Get name and vote count for a specific candidate
    function getResults(uint candidateIndex) public view returns (string memory name, uint voteCount) {
        require(candidateIndex < candidates.length, "Invalid candidate");
        Candidate memory c = candidates[candidateIndex];
        return (c.name, c.voteCount);
    }

    // Get total number of candidates
    function getCandidateCount() public view returns (uint) {
        return candidates.length;
    }

    // Get time remaining in seconds — returns 0 if voting is closed
    function getTimeRemaining() public view returns (uint) {
        if (!votingActive || block.timestamp > votingEnd) {
            return 0;
        }
        return votingEnd - block.timestamp;
    }

    // Check if voting is currently open — returns true or false
    function isVotingOpen() public view returns (bool) {
        return votingActive &&
            block.timestamp >= votingStart &&
            block.timestamp <= votingEnd;
    }
}
```

---

### Key Concepts in the Contract

| Concept | What it means |
|---|---|
| `msg.sender` | The wallet address of whoever is calling the function right now. Cannot be faked. |
| `require()` | Enforces a rule. If the condition fails — transaction reverts, nothing changes on chain |
| `mapping` | A lookup table. Like a dictionary — given a wallet address, return their voter info |
| `storage` | Points directly to on-chain data. Changes are permanent |
| `memory` | A temporary copy. Used for reading, thrown away after the function runs |
| `block.timestamp` | The current time on the blockchain in Unix seconds |
| `emit` | Broadcasts an event to the blockchain — shows up on Etherscan as a log |
| `view` | Read-only function — always free, no gas, no MetaMask popup |
| `public` | Anyone can call this function |
| `onlyOwner` | Only the wallet that deployed the contract can call this |

---

## Step 1 — Set Up MetaMask

1. Go to [metamask.io](https://metamask.io)
2. Click **Download** and install the browser extension for Chrome or Firefox
3. Click **Create a new wallet**
4. Create a password
5. **Write down your 12-word Secret Recovery Phrase on paper — keep it safe offline**
6. Never share your recovery phrase with anyone — not MetaMask support, not a website, not anyone

**Add Sepolia Testnet:**
1. Click the network dropdown at the top of MetaMask (shows "Ethereum Mainnet")
2. Click **Add a network**
3. Click **Add a network manually** or look for Sepolia in the Popular Networks list
4. If adding manually, use these details:

```
Network Name:    Sepolia Test Network
RPC URL:         https://rpc.sepolia.org
Chain ID:        11155111
Currency Symbol: ETH
Block Explorer:  https://sepolia.etherscan.io
```

5. Click Save
6. Switch to Sepolia Test Network ✅

> If you don't see testnets: Go to Settings → Advanced → toggle on "Show test networks"

---

## Step 2 — Get Sepolia Test ETH

You need a tiny amount of Sepolia ETH to pay for gas. It's completely free.

**Recommended faucet — no account needed:**
1. Go to [cloud.google.com/application/web3/faucet/ethereum/sepolia](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
2. Make sure MetaMask is on Sepolia Test Network
3. Copy your wallet address from MetaMask (click your address at the top)
4. Paste it into the faucet
5. Click request
6. Wait 30-60 seconds
7. Check MetaMask — you should see a small Sepolia ETH balance ✅

**Backup faucets if Google is slow:**
- [sepoliafaucet.com](https://sepoliafaucet.com) — free Alchemy account needed
- [infura.io/faucet/sepolia](https://infura.io/faucet/sepolia) — free Infura account needed
- [faucets.chain.link](https://faucets.chain.link) — connect MetaMask directly

> How much do you need? About 0.05 ETH covers everything in this workshop. The Google faucet gives exactly that.

---

## Step 3 — Open Remix IDE

1. Go to [remix.ethereum.org](https://remix.ethereum.org) in your browser
2. In the file explorer on the left — click the **+** icon to create a new file
3. Name it `SimpleVote.sol`
4. Copy the full contract code from above and paste it in
5. You should see the Solidity code in the editor ✅

---

## Step 4 — Compile the Contract

1. Click the **Solidity Compiler** tab on the left sidebar (looks like an S)
2. Make sure the compiler version is **0.8.0 or higher**
3. Click **Compile SimpleVote.sol**
4. Wait 2-3 seconds

**What to look for:**
- ✅ Green checkmark — compiled successfully, ready to deploy
- ⚠️ Yellow warnings — fine, you can ignore these
- ❌ Red errors — something is wrong, check the compiler version matches your pragma

---

## Step 5 — Deploy on Remix VM (Local Test)

Before touching the real blockchain — test everything locally first.

1. Click the **Deploy & Run Transactions** tab (Ethereum diamond icon)
2. In the **Environment** dropdown — select **Remix VM (Cancun)**
3. You'll see fake accounts with 100 ETH each — use these for testing
4. Make sure **SimpleVote** is selected in the contract dropdown
5. Click the orange **Deploy** button
6. Your contract appears under **Deployed Contracts** at the bottom
7. Click the arrow to expand — all functions appear as buttons

**Test every function in this order:**

```
1. addCandidate → "Ethereum" → transact
2. addCandidate → "Solana" → transact
3. addCandidate → "Base" → transact
4. addCandidate → "AI Agents" → transact

5. getCandidateCount → call → should return 4 ✅

6. startVoting → 60 → transact

7. isVotingOpen → call → should return true ✅
8. getTimeRemaining → call → should return ~3600 ✅

9. registerVoter → 25 → transact
10. castAVote → 2 → transact

11. getResults → 2 → call → should show "Base", 1 vote ✅

12. castAVote → 2 → transact again
    → Should FAIL: "You have already voted" ✅

13. stopVoting → transact
14. isVotingOpen → call → should return false ✅
```

> 💡 Orange buttons = write functions = cost gas = MetaMask will pop up on Sepolia
> 💡 Blue buttons = view functions = free = no MetaMask popup ever

---

## Step 6 — Deploy to Sepolia Testnet

Now deploy to a real blockchain.

**Switch MetaMask to Sepolia:**
1. Open MetaMask
2. Click the network dropdown
3. Select **Sepolia Test Network**
4. Confirm your Sepolia ETH balance is showing

**Connect Remix to MetaMask:**
1. In Remix Deploy tab
2. Environment dropdown → select **Browser Extension**
3. MetaMask pops up asking to connect → click **Connect**
4. Your real wallet address appears in Remix ✅

> ⚠️ Double check MetaMask shows **Sepolia Test Network** before deploying. Never deploy to Ethereum Mainnet by accident — that costs real money.

**Deploy:**
1. Make sure **SimpleVote** is selected in contract dropdown
2. Click orange **Deploy** button
3. MetaMask pops up — review the transaction
4. Click **Confirm**
5. Wait 15-30 seconds for confirmation
6. Green tick appears in Remix console ✅
7. Your contract address appears under Deployed Contracts

**Find your contract address:**
- Look under **Deployed Contracts** in Remix
- You'll see `SIMPLEVOTE AT 0x1234...ABCD`
- Click the copy icon to copy your address
- **Save this address — it's your contract's permanent home on the blockchain**

**Verify on Etherscan:**
1. Go to [sepolia.etherscan.io](https://sepolia.etherscan.io)
2. Paste your contract address
3. You should see your deployment transaction ✅
4. Your contract is now live on a real blockchain 🎉

---

## Step 7 — Vote on the Workshop Contract

During the workshop — everyone votes on the same shared contract. Here's how to connect to it:

**You will receive the workshop contract address in the group chat.**

**Steps:**
1. In Remix — go to Deploy tab
2. Environment → **Browser Extension** → connect MetaMask
3. Make sure MetaMask is on **Sepolia Test Network**
4. In the contract dropdown — select **SimpleVote**
5. Find the **At Address** field below the Deploy button

```
⚠️ DO NOT click the Deploy button
✅ Paste the workshop contract address → click At Address
```

6. All functions appear — now connected to the shared contract
7. Call **registerVoter()** → enter your age → confirm in MetaMask
8. Call **castAVote()** → enter the candidate number → confirm in MetaMask

**Candidate numbers:**
```
0 — Ethereum
1 — Solana
2 — Base
3 — AI Agents
```

---

## Step 8 — View Results on Etherscan

**In Remix:**
```
getResults(0) → Ethereum: X votes
getResults(1) → Solana: X votes
getResults(2) → Base: X votes
getResults(3) → AI Agents: X votes
```

**On Etherscan:**
1. Go to [sepolia.etherscan.io](https://sepolia.etherscan.io)
2. Paste the workshop contract address
3. Click **Transactions** tab — see every vote as a transaction
4. Click **Contract** tab → **Read Contract** → call getResults for each candidate

---

## Contract Reference

### Owner Functions (only the deployer can call these)

| Function | Input | What it does |
|---|---|---|
| `addCandidate(name)` | string | Adds a candidate before voting starts |
| `startVoting(minutes)` | uint | Opens voting for X minutes |
| `stopVoting()` | none | Closes voting immediately |

### Voter Functions (anyone can call these)

| Function | Input | What it does |
|---|---|---|
| `registerVoter(age)` | uint | Registers you as a voter — must be 18+ |
| `castAVote(index)` | uint | Casts your vote for candidate at that index |

### View Functions (always free — no gas)

| Function | Input | Returns |
|---|---|---|
| `getResults(index)` | uint | Candidate name and vote count |
| `getCandidateCount()` | none | Total number of candidates |
| `getTimeRemaining()` | none | Seconds remaining in voting window |
| `isVotingOpen()` | none | true or false |

---

## Troubleshooting

| Problem | Solution |
|---|---|
| MetaMask not connecting to Remix | Refresh Remix, switch environment to Remix VM then back to Browser Extension |
| Wrong network in MetaMask | Click network dropdown → select Sepolia Test Network |
| Sepolia ETH faucet is slow | Try a backup faucet or use Remix VM for the coding section |
| Transaction stuck as pending | In MetaMask → Activity → Speed Up the transaction |
| Can't find At Address field | It's just below the Deploy button in the Deploy tab — scroll down |
| SimpleVote not in dropdown | Make sure you compiled the contract first — green checkmark needed |
| "You have already voted" error | Each wallet can only vote once — this is working as intended ✅ |
| "Only owner can perform this action" | You're trying to call an owner function from a non-owner wallet |
| Red error on compile | Check compiler version matches pragma solidity ^0.8.0 |

---

## What's Next

You just deployed a real smart contract to the Ethereum blockchain. Here's where to go from here:

**Workshop Series:**
- **Workshop 01** — This workshop ✅ Smart contracts, Remix, MetaMask, Sepolia
- **Workshop 02** — Frontend for Web3. Connect React to your contract with ethers.js and wagmi
- **Workshop 03** — Production dApps. Hardhat, mainnet deployment, testing and security

**Free Learning Resources:**
- [CryptoZombies](https://cryptozombies.io) — Learn Solidity by building a game
- [Buildspace](https://buildspace.so) — Build real Web3 projects
- [Alchemy University](https://university.alchemy.com) — Deep technical Web3 education
- [Sepolia Etherscan](https://sepolia.etherscan.io) — Explore your transactions

**Join the Community:**
**Tiramisoo** — A community for curious, technical, creative people who want to go deep in Web3 and AI. Workshops, dinners, build nights, heritage trips and more.

*No hype. No fluff. Just builders.*

---

## About

Built with ❤️ by **Garima** for Toronto Tech Week 2026

[Deep Tech Studios](https://www.deeptechink.ca) · [Twitter/X](https://x.com/GarimaA60302335) · [LinkedIn](#)

> *"The people in this room are exactly who Tiramisoo is for."* 🥭
