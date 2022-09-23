import { ethers } from "hardhat";

async function main() {
  const Trendsol = await ethers.getContractFactory("Trendsol");
  const trendsol = await Trendsol.deploy();

  await trendsol.deployed();

  console.log(`Trendsol deployed to ${trendsol.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
