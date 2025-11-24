const { deployments,upgrades, ethers } = require("hardhat");


//存储deploy脚本对应的合约地址
const fs = require("fs");
const path = require("path");
const { json } = require("stream/consumers");
const { log } = require("console");

module.exports = async ({getNamedAccounts, deployments}) => {
  //将部署内容保存在运行时环境中,方便后续调用
  const { save } = deployments;
  
  //获取配置的hardhat.config.js中的namedAccounts的值
  const {deployer} = await getNamedAccounts();

  console.log("部署人的合约地址：",deployer);
  
  //获取MYNFT的合约
  const myNFT = await deployments.get("MyERC721");
  console.log("myNFT的合约地址:",myNFT.address);

  const erc721Contract = await ethers.getContractAt("MyERC721", myNFT.address);
  log("执行mint函数")
  await erc721Contract.mintNFT(deployer,"https://ipfs.io/ipfs/bafkreid6b6xpe36wiff2rzzfps6fqoubh6zeqpeiga7xeshhp3ckbgyqsq");
  log("执行完成mint函数")
  
  
  //使用代理方式部署
  //合约名称,合约初始函数传参,合约的初始函数名称
  const MyAuctionUp = await ethers.getContractFactory("MyAuctionUp");
  const proxyContract = await upgrades.deployProxy(MyAuctionUp,[],{
    initializer: "initialize",
  })

  //等待合约部署完成
  await proxyContract.waitForDeployment();

  //打印代理合约地址
  const proxyAddress =  await proxyContract.getAddress();
  console.log("代理合约地址",proxyAddress);

  //真实合约地址
  const implementAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress)
  console.log("真实合约地址",implementAddress);

  //拼接存储路径
  const soretPath = path.resolve(__dirname,"../address/proxyNFTContract.json")
  
  //将地址写入拼接的存储路径中
  fs.writeFileSync(
    soretPath,
    JSON.stringify({
      proxyAddress: proxyAddress,
      implementAddress: implementAddress,
      abi: MyAuctionUp.interface.format("json")
    })
  );
  //在运行环境中存储地址信息
  //存放的信息起一个名字，用来获取
  //后面就是存放的json
  await save("NFTContrctproxy",{
    abi: MyAuctionUp.interface.format("json"),
    address: proxyAddress
    // args: [],
    // log: true
  })

};
module.exports.tags = ['MyAuctionDeploy'];