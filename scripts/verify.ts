import { run } from "hardhat";

async function main() {
  try {
  const ADMIN = "0xB3DAB3a5FB6cD45758FAcFA2C8BA66b00aB2AD7c";
  const USDT = "0x55d398326f99059fF775485246999027B3197955";
  const GORA = "0x6F0A91faf4c4a97Da80902c254012c06d02bF56D";
  const GORALP = "0x1198F383FFb86fE412D7433D96fB23F06c312623";
  const Purchase = "0x8BCdF502f83CD877E3E4Fca48Bdd7CA9a7dCC3dC";



    // GORA
    await run("verify:verify", {
      address: GORA,
      constructorArguments: [ADMIN],
    });

    // GORA LP
    await run("verify:verify", {
      address: GORALP,
      constructorArguments: [USDT, GORA, ADMIN],
    });

    // GORA purchase
    await run("verify:verify", {
      address: Purchase,
      constructorArguments: [ADMIN, GORALP, USDT, GORA],
    });


    console.log("Contract successfully verified on Etherscan!");
  } catch (error) {
    console.error(" Verification failed:", error);
    process.exit(1);
  }
}

main();
