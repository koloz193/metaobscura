import { ethers, upgrades } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account: ",
    deployer.address
  );

  console.log("Deploying Receiver Contract...");

  const MetaObscuraReceiver = await ethers.getContractFactory("MetaObscuraReceiver");
  const receiverProxy = await upgrades.deployProxy(
    MetaObscuraReceiver, 
    [
      "0xcae2874732acb94ff38c98b5812395f0f342fd69",
      90,
      "0x6d04ff6fd2c61f41fc1c8e461ce7a9908c3e4a62",
      1,
      10
    ], 
    { initializer: 'init' }
  );
  await receiverProxy.deployed();

  console.log("Receiver Proxy address: ", receiverProxy.address);
};

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });