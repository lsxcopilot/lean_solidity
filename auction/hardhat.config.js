const { task } = require("hardhat/config");

require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
//合约部署插件 
require("hardhat-deploy");
//导入upgrade，用于合约可升级
require("@openzeppelin/hardhat-upgrades");
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  namedAccounts:{
    deployer: 0,
    user1:1,
    user2:2
  },
  networks:{
    sepolia:{
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};

//task("任务名称"，”任务描述“，异步线程(taskArgs：任务参数，hre：hardhat运行时环境)=》{ 逻辑执行体 })
//执行任务指令：npx hardhat 任务名称
task("myTask","get account list",async (taskArgs,hre)=>{
    const accounts =await hre.ethers.getSigners();
    for(const account of accounts){
        console.log(account.address);
    }
})
