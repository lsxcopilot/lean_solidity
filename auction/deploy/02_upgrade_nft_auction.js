//合约升级脚本：升级合约，保有原来的合约状态
const { ethers, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { save } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("部署用户地址" + deployer);

  //读取之前部署的代理合约地址
  const storePath = path.join(__dirname, "./proxyNftAuction.json");
  const proxyData = fs.readFileSync(storePath, "utf-8");
  const { proxyAddress,implementaion,abi } = JSON.parse(proxyData);
  
  console.log("读取到的代理合约地址为：", proxyAddress);

  //升级版本的业务合约
    const NftAuctionV2 = await ethers.getContractFactory("NftAuctionV2");

    //升级代理合约
    const upgraded = await upgrades.upgradeProxy(proxyAddress, NftAuctionV2);
    await upgraded.waitForDeployment();
    console.log("合约升级完成，新的实现合约地址为：", await upgrades.erc1967.getImplementationAddress(proxyAddress));
}

module.exports.tags = ["UpgradeNftAuction"];