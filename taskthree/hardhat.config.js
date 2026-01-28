require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    //配置sepolia网络
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY_ONE,process.env.PRIVATE_KEY_TWO],
      chainId: 11155111
    }
  },
  namedAccounts:{
    deployer: {
      default: 0,
      sepolia: 1
    },
    user1: 1,
    user2: 2,
  }
};

//hardhat的任务模块(task名称，描述，异步线程函数：(任务参数，hardhat运行环境),逻辑代码)
//npx hardhat accounts 执行任务指令
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  //获取账户列表
  const accounts = await hre.ethers.getSigners();

  //循环输出账户列表地址
  for (const account of accounts) {
    console.log(account.address);
  }
});