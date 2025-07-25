# PotteryChain

A decentralized ceramic pottery and clay arts reward system for incentivizing traditional pottery craftsmanship on Stacks blockchain.

## Features

- Pottery activity tracking with firing duration-based rewards
- Potter ceramic level progression with mastery bonus multipliers
- Pottery token accumulation and redemption system
- Clay preservation mechanism with time-based penalties
- Comprehensive kiln statistics and analytics

## Smart Contract Functions

### Public Functions
- `start-pottery-activity` - Begin ceramic pottery session
- `complete-pottery-piece` - Complete piece and earn rewards
- `claim-pottery-rewards` - Claim accumulated pottery tokens
- `preserve-clay` - Preserve clay for enhanced rewards
- `release-preserved-clay` - Release preserved clay with potential penalties

### Read-Only Functions
- `get-pottery-activity-count` - Get user's total pottery activities
- `get-pottery-token-balance` - Get user's pottery token balance
- `get-ceramic-level` - Get user's ceramic mastery level
- `get-kiln-stats` - Get overall kiln statistics

## Reward System
- Base reward: 22 tokens per piece
- Ceramic bonus: 8 tokens per level (max level 12)
- Clay preservation multiplier: 4x for preserved clay
- Kiln capacity: 1.8M total tokens

## Usage

Deploy the contract to create a pottery system where ceramic artists can track their clay arts activities, earn rewards, and preserve clay for enhanced benefits.

## License

MIT