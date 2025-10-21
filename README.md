Purchase Contract – Hardhat Project

This project implements and tests a DeFi Purchase Contract that integrates:

BUSD (ERC20)

GORA (ERC20)

GORALP (Liquidity Pool)

Purchase Contract for token buying, rebuying, selling, and liquidity management.

It uses Hardhat + TypeScript + Chai for testing.

📦 Project Setup
1. Clone Repository & Install Dependencies
git clone <repo-url>
cd <repo-folder>
npm install

2. Compile Contracts
npx hardhat compile

3. Run Tests
npx hardhat test

4. Run Single Test File
npx hardhat test test/PurchaseContract.ts

⚙️ Contracts Overview
1. BUSD (Mock ERC20)

Basic ERC20 stablecoin for testing.

Initially assigned to Admin.

2. GORA (ERC20)

Main project token.

Controlled by Admin.

Supports minting/burning via CONTROLLER_ROLE.

3. GORALP (Liquidity Pool)

Custom liquidity pool handling BUSD ↔ GORA swaps.

Supports price discovery (getPrice()).

Allows liquidity addition/removal by Admin.

4. Purchase Contract

Main contract for user interaction.

Features:

Buy(uint256 amount) – Buy GORA with BUSD.

reBuy(uint256 amount) – Reinvest BUSD into GORA.

sell(uint256 amount) – Sell GORA back to BUSD.

addLiquidity(uint256 amount) – Admin adds liquidity to LP.

withdrawShare() – Admin withdraws LP shares.

getUserDetails(address user) – Fetch user investment details.

getSellTokenAmount(uint256 goraAmount) – Estimate BUSD received on selling GORA.

 Test Cases

Located in: test/PurchaseContract.ts

User Scenarios

 Deploy LP, check initial price.

 Buy GORA with BUSD.

 ReBuy GORA after initial purchase.

 Sell GORA back to BUSD.

 Check updated LP reserves and price after each action.

Admin Scenarios

 Add liquidity into LP.

 Withdraw shares.

 Validate price updates correctly.

Complex Scenario (Combined Flow)

User buys GORA with BUSD.

Admin adds liquidity.

User sells GORA (burn event validation).

User rebuys with BUSD.

Admin adds more liquidity.

User sells again with updated price checks.

🚀 Example Test Run
GORA: 0x...
BUSD: 0x...
lp: 0x...
purchase: 0x...

# Scenario Logs
Price: 0.01 BUSD per GORA
User Details: [balance, invested, withdrawn, etc...]
Sell Volume Calculated: 123
SellTokenAmount: 2000

📂 Project Structure
contracts/
 ├── BUSD.sol
 ├── GORA.sol
 ├── GORALP.sol
 └── Purchase.sol
test/
 └── PurchaseContract.ts
hardhat.config.ts
package.json

🛠️ Tech Stack

Hardhat
 – Smart contract development framework

Ethers.js
 – Blockchain interaction

Chai
 – Testing assertions

TypeScript
 – Strong typing

