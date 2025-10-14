Purchase Contract – Hardhat Project

This project implements and tests a DeFi Purchase Contract that integrates:

USDT (ERC20)

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
1. USDT (Mock ERC20)

Basic ERC20 stablecoin for testing.

Initially assigned to Admin.

2. GORA (ERC20)

Main project token.

Controlled by Admin.

Supports minting/burning via CONTROLLER_ROLE.

3. GORALP (Liquidity Pool)

Custom liquidity pool handling USDT ↔ GORA swaps.

Supports price discovery (getPrice()).

Allows liquidity addition/removal by Admin.

4. Purchase Contract

Main contract for user interaction.

Features:

Buy(uint256 amount) – Buy GORA with USDT.

reBuy(uint256 amount) – Reinvest USDT into GORA.

sell(uint256 amount) – Sell GORA back to USDT.

addLiquidity(uint256 amount) – Admin adds liquidity to LP.

withdrawShare() – Admin withdraws LP shares.

getUserDetails(address user) – Fetch user investment details.

getSellTokenAmount(uint256 goraAmount) – Estimate USDT received on selling GORA.

 Test Cases

Located in: test/PurchaseContract.ts

User Scenarios

 Deploy LP, check initial price.

 Buy GORA with USDT.

 ReBuy GORA after initial purchase.

 Sell GORA back to USDT.

 Check updated LP reserves and price after each action.

Admin Scenarios

 Add liquidity into LP.

 Withdraw shares.

 Validate price updates correctly.

Complex Scenario (Combined Flow)

User buys GORA with USDT.

Admin adds liquidity.

User sells GORA (burn event validation).

User rebuys with USDT.

Admin adds more liquidity.

User sells again with updated price checks.

🚀 Example Test Run
GORA: 0x...
USDT: 0x...
lp: 0x...
purchase: 0x...

# Scenario Logs
Price: 0.01 USDT per GORA
User Details: [balance, invested, withdrawn, etc...]
Sell Volume Calculated: 123
SellTokenAmount: 2000

📂 Project Structure
contracts/
 ├── USDT.sol
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





 *🌟 You're Invited: Townhall Time! 🌟*

*🗓 Agenda:*

_1️⃣ Team Updates_
 🔧 Tech Team
 👥 D5art Emp Team
 📚 D5art Edu Team
 🧠 Creative Team

_2️⃣ Fun Game Activity 🎮_
_3️⃣  Closing Talk 🎤_

🕓 When: Today at 5:30 PM IST | 4:00 PM GST  
*🔗 Join Meeting:*
https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZGM2MDM3YjQtMDBhYS00ZTc2LTkwZmItZmM0NjdlMmI4ZjQ0%40thread.v2/0?context=%7b%22Tid%22%3a%223bd08ab7-5102-4cd6-870a-23a343442664%22%2c%22Oid%22%3a%22cc84722f-83a5-477c-ba7b-7745f7d14473%22%7d

📅 Date: 09 oct, 2025
⏰ 5:30 PM – 6:30 PM (GMT+05:30)

_📣 Team Leads – Please be ready with your updates!_