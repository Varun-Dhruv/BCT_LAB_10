import { ethers } from "hardhat";
import { RES4Token } from "../typechain-types";

async function main() {
  const RES4TokenFactory = await ethers.getContractFactory("RES4Token");
  const res4Token = await RES4TokenFactory.deploy();

  console.log("RES4Token deployed to:", res4Token.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

