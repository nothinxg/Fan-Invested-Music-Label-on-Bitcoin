# 🎵 Fan-Invested Music Label on Bitcoin

A decentralized music label platform built on Bitcoin (Stacks) where fans can invest in their favorite artists by staking STX tokens and earn proportional revenue from streaming income.

## 🌟 Overview

This smart contract enables a revolutionary crowdfunding model for music production where:
- 🎤 **Artists** create funding campaigns for songs/albums
- 💰 **Fans** stake STX to support production
- 📊 **Revenue sharing** is automated and proportional to stake
- 🔒 **Trustless** distribution via smart contract logic

## ✨ Features

- **Artist Registration**: Musicians register on the platform
- **Campaign Creation**: Artists create funding campaigns for songs/albums
- **Fan Staking**: Fans stake STX tokens to support campaigns
- **Goal-Based Funding**: Campaigns must reach goals before artist receives funds
- **Revenue Distribution**: Automated proportional revenue sharing
- **Stake Withdrawal**: Fans can withdraw stakes from unfunded campaigns
- **Reward Claims**: Fans claim their share of streaming revenue

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for testing

### Installation

```bash
git clone <repository-url>
cd Fan-Invested-Music-Label-on-Bitcoin
clarinet check
```

## 📖 Usage

### For Artists

#### 1. Register as Artist
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin register-artist "Artist Name")
```

#### 2. Create Song Campaign
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin create-song "Song Title" u1000000)
```
*Creates campaign with 1,000,000 microSTX funding goal*

#### 3. Close Funding (when goal reached)
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin close-funding u1)
```

#### 4. Add Revenue from Streams
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin add-revenue u1 u500000)
```
*Deposits 500,000 microSTX revenue for song ID 1*

### For Fans

#### 1. Stake on Song
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin stake-on-song u1 u100000)
```
*Stakes 100,000 microSTX on song ID 1*

#### 2. Check Claimable Rewards
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin get-claimable-rewards tx-sender u1)
```

#### 3. Claim Rewards
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin claim-rewards u1)
```

#### 4. Withdraw Stake (if campaign not funded)
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin withdraw-stake u1)
```

## 🔍 Read-Only Functions

### Get Artist Info
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin get-artist 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Get Song Details
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin get-song u1)
```

### Get Stake Info
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin get-stake 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u1)
```

### Get Platform Statistics
```clarity
(contract-call? .Fan-Invested-Music-Label-on-Bitcoin get-platform-stats)
```

## 🏗️ Contract Architecture

### Data Structures

- **Artists**: Stores registered artist information
- **Songs**: Campaign details including funding goals and revenue
- **Stakes**: Individual fan investments per song
- **Song Stakers**: Tracks number of stakers per song

### Core Functions

| Function | Description |
|----------|-------------|
| `register-artist` | Register as a music artist |
| `create-song` | Create a new funding campaign |
| `stake-on-song` | Invest STX in a campaign |
| `close-funding` | Finalize campaign and transfer funds to artist |
| `add-revenue` | Artist deposits streaming revenue |
| `claim-rewards` | Fans claim their revenue share |
| `withdraw-stake` | Withdraw from unfunded campaign |

## 💡 Example Workflow

1. **Artist Registration**: Alice registers as "Alice Music"
2. **Campaign Creation**: Alice creates campaign for "Summer Vibes" with 10 STX goal
3. **Fan Investment**: 
   - Bob stakes 6 STX (60% ownership)
   - Carol stakes 4 STX (40% ownership)
4. **Funding Close**: Alice closes funding, receives 10 STX
5. **Revenue**: Alice adds 5 STX from streaming revenue
6. **Claims**:
   - Bob claims 3 STX (60% of 5 STX)
   - Carol claims 2 STX (40% of 5 STX)

## 🔐 Security Features

- ✅ Owner-only functions protected
- ✅ Campaign status validation
- ✅ Stake amount verification
- ✅ Revenue calculation precision
- ✅ Authorization checks for artists

## 🧪 Testing

```bash
clarinet test
```

## 📝 Error Codes

| Code | Description |
|------|-------------|
| u100 | Owner only |
| u101 | Not found |
| u102 | Already exists |
| u103 | Invalid amount |
| u104 | Campaign closed |
| u105 | Campaign active |
| u106 | No stake |
| u107 | No revenue |
| u108 | Unauthorized |
| u109 | Invalid status |

## 🤝 Contributing

Contributions welcome! Please open an issue or submit a pull request.

## 📄 License

MIT License

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co)
- [Clarity Language](https://docs.stacks.co/clarity)
- [Clarinet](https://github.com/hirosystems/clarinet)

---

Built with ❤️ on Bitcoin (Stacks Blockchain)
