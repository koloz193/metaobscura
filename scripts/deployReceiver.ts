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
      "0xCAe2874732aCB94FF38c98b5812395F0f342fd69",
      90,
      "0xD5A498Bbc6D21E4E1cdBB8fec58e3eCD7124FB43",
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