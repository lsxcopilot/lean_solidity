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
  /**
   * 根据地址获取对应的签名者（signer）对象。
   *  包含一个以太坊地址
      有私钥，可以签名交易
      可以发送交易、支付 gas
      相当于一个"可以操作账户"的对象
   */
  const signer = await ethers.getSigner(deployer);
  console.log("部署人的合约地址：",deployer);
  
  //获取MYNFT的合约
  const myNFT = await deployments.get("MyERC721");
  console.log("myNFT的合约地址:",myNFT.address);

  /**
   * deployments.get("MyAuctionUp") 返回的是部署记录对象，
   * 不是合约实例。它包含 address、abi、receipt 等信息，但没有 interface 属性。
   */
  const myAuctionUpDeploy = await deployments.get("MyAuctionUp");
  console.log("myAuctionUpDeploy的合约地址:",myAuctionUpDeploy.address);

  /**
   * await ethers.getContractAt("MyERC721", myNFT.address)
      特点：连接到默认 provider，没有签名者
      权限：只能调用 view 和 pure 函数（只读函数）
      不能：发送交易（如 mint、transfer、approve 等）
      错误：调用需要 gas 的函数时会报错

    await ethers.getContractAt("MyERC721", myNFT.address, signer)
      特点：连接到特定签名者（有私钥的账户）
      权限：可以调用所有函数，包括需要发送交易的操作
      可以：发送交易、支付 gas、更改链上状态

      总结：
      没有 signer：像在浏览器查看合约（只读模式）
      有 signer：像用 MetaMask 连接合约（可读写模式）
   */

  const erc721Contract = await ethers.getContractAt("MyERC721", myNFT.address,signer);
  log("执行mint函数")
  //0xfE1d3b475B9C0072681deC2De6b36EA83A5edfc6
  const balance = await ethers.provider.getBalance(deployer);
  
  console.log("当前部署账户:", deployer);
  console.log("账户余额:", ethers.formatEther(balance), "ETH");
  
  await erc721Contract.mintNFT(deployer,"https://ipfs.io/ipfs/bafkreid6b6xpe36wiff2rzzfps6fqoubh6zeqpeiga7xeshhp3ckbgyqsq");
  log("执行完成mint函数")
  
  
  //使用代理方式部署
  //合约名称,合约初始函数传参,合约的初始函数名称
  //从 artifacts/ 目录读取 MyAuctionUp 合约的 ABI 和字节码 创建一个合约工厂对象
  /**
   *  await ethers.getContractFactory("MyAuctionUp")
   *  特点：
          使用 ethers.getSigners() 返回的第一个账户
          部署合约时，gas 费从这个账户扣除
          合约方法调用默认使用这个账户的私钥签名

      await ethers.getContractFactory("MyAuctionUp", signer)
      特点：
        使用指定的账户作为部署人
        合约调用时使用指定账户的私钥
        gas 费从指定账户扣除

      权限敏感：必须指定 signer 以确保正确的账户拥有权限
   */
  const MyAuctionUp = await ethers.getContractFactory("MyAuctionUp",signer);
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
      abi: MyAuctionUp.interface.format("json"),
      bin: MyAuctionUp.bytecode
    })
  );

  const myAuctionUpABI = path.resolve(__dirname,"../address/myAuctionUpABI.abi")
  const abi = myAuctionUpDeploy.abi;
  //const abi = myAuctionUpDeploy.interface.
  //写入abi文件
  fs.writeFileSync(
    myAuctionUpABI,
    JSON.stringify(abi, null, 2)
  );

  //写入bin文件
  const myAuctionUpBIN = path.resolve(__dirname,"../address/myAuctionUpBIN.bin")
  fs.writeFileSync(
    myAuctionUpBIN,
    myAuctionUpDeploy.bytecode
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