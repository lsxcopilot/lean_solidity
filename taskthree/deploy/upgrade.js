const { deployments,ethers,upgrades } = require("hardhat")
const path = require("path")
const fs = require("fs")
const { log } = require("console");

module.exports = async ({getNamedAccounts,deployments}) =>{
    const { save } = deployments;
    const { deployer } = await getNamedAccounts();
    console.log("当前升级地址：",deployer)
    //读取文件
   const readPath = await path.resolve(__dirname,"../address/proxyNFTContract.json");
   
   //获取内容
   const readData = await fs.readFileSync(readPath,"utf-8");
   const { proxyAddress,implementAddress,abi } = await JSON.parse(readData);

   //升级版的业务合约
   const MyAuctionV2 = await ethers.getContractFactory("MyAuctionV2");
   
   //调用升级方法,获取代理合约实例
   const v2 =  await upgrades.upgradeProxy(proxyAddress,MyAuctionV2);
   await v2.waitForDeployment();

   //获取新的合约地址
   const v2Address = await v2.getAddress();
   console.log("新的升级后的合约地址",v2Address)

   await save("proxyV2",{
    abi,
    address: v2Address
   })
};

module.exports.tags = ['upNFTContractProxy'];
