// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "hardhat";

const USDT = "0x55d398326f99059fF775485246999027B3197955";

const LockModule = buildModule("GORA", (m) => {

  const ADMIN = m.getAccount(0);

  //GORA deployment
    const GORA = m.contract("GORA", [ADMIN]);

  //LP deployment

    const GORALP = m.contract("GORALP", [USDT, GORA, ADMIN]);

  //purchase deployment 

    const Purchase = m.contract("Purchase", [ADMIN, GORALP, USDT, GORA]);

    // //const ADMIN_ROLE = ethers.keccak256(ethers.toUtf8Bytes("ADMIN_ROLE"));
    // const CONTROLLER_ROLE = ethers.keccak256(ethers.toUtf8Bytes("CONTROLLER_ROLE"));

  //grantRole
    m.call(GORALP, "grantRole", ["0x70546d1c92f8c2132ae23a23f5177aa8526356051c7510df99f50e012d221529", Purchase]);
    m.call(GORALP, "setController", [Purchase])
    m.call(GORA, "grantRole", ["0x70546d1c92f8c2132ae23a23f5177aa8526356051c7510df99f50e012d221529", Purchase]);

  return {GORA, GORALP,  Purchase};
});

export default LockModule;
