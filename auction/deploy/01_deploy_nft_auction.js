//合约部署脚本
//deployments - 部署管理 用于智能合约的部署和交互
//upgrades - 可升级合约 用于部署和管理可升级合约（基于 OpenZeppelin）
const { deployments,upgrades, ethers } = require("hardhat")

const fs = require("fs");
const path = require("path");

// deploy/00_deploy_my_contract.js
// export a function that get passed the Hardhat runtime environment
// module.exports 这是 Node.js 的模块导出语法 Hardhat 会执行这个导出的函数来部署合约
module.exports = async ({ getNamedAccounts, deployments }) => {

    /**
     *  从 deployments 对象中解构出 save 方法
        save 用于保存自定义的部署记录到 Hardhat 的部署系统中
        通常用于保存代理合约、外部合约地址等信息
     */
  const { save } = deployments;

    /**
     *  调用 getNamedAccounts() 获取在 hardhat.config.js 中预定义的账户
        解构出 deployer 账户（部署者账户）
        deployer 是用于支付 gas 费和部署合约的账户
     */
  const { deployer } = await getNamedAccounts();
  console.log("部署合约地址：" + deployer);

    //获取合约工厂
    const NftAuction = await ethers.getContractFactory("NftAuction");

    //通过代理合约部署：指定合约工厂、构造函数参数、初始化函数
    const nftAuction = await upgrades.deployProxy(NftAuction, [], { 
        //指定初始化函数
        initializer: 'initializable' 
    });
    //等待合约部署完成
    await nftAuction.waitForDeployment();

    const proxyAddress = await nftAuction.getAddress();
    console.log("代理合约地址为：",proxyAddress);
    const implementaion = await upgrades.erc1967.getImplementationAddress(proxyAddress)
    console.log("真实合约地址为：",implementaion);

    //保存部署信息到文件
    const storePath = path.join(__dirname, "./proxyNftAuction.json");


    /**
     * 这两者虽然都用于保存数据，但目的和使用场景完全不同：
        fs.writeFileSync - 文件系统写入
        作用：
            将数据写入到本地文件
            生成供前端或其他外部应用使用的配置文件

        save - Hardhat 部署系统存储
        作用：
            将部署信息保存到 Hardhat 的内部部署记录系统
            用于后续的部署脚本和测试中获取合约信息
            Hardhat 集成：可以通过 deployments.get('NftAuctionProxy') 获取
            部署链：在复杂部署中，后续脚本可以依赖这些记录
            测试使用：测试文件中可以直接获取部署的合约实例
            环境管理：Hardhat 会管理不同网络的部署记录
     */
    fs.writeFileSync(
        storePath,
        JSON.stringify(
            {
                proxyAddress: proxyAddress,
                implementaion: implementaion,
                abi: NftAuction.interface.format("json"),
            }
        )
    );

    await save("NftAuctionProxy", {
      address: proxyAddress,
      abi: NftAuction.interface.format("json"),
    })

//   await deploy("NftAuction", {
//     from: deployer,
//     args: ["Hello"],
//     log: true,
//   });
};
// add tags and dependencies
//定义脚本标签NftAuction
module.exports.tags = ["NftAuction"];