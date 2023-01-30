const { ethers } = require("hardhat");

async function main() {
  const ICO_CONTRACT_ADDRESS = "0xF4c10044f15031598FE52dAec8eBe16F71145284"

  const ExchangeContract = await ethers.getContractFactory("Exchange");
  const deployExchangeContract = await ExchangeContract.deploy(ICO_CONTRACT_ADDRESS);
  await deployExchangeContract.deployed();

  console.log("Contract Address is "+ deployExchangeContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
