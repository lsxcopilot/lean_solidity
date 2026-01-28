const { deployments,getNamedAccounts } = require("hardhat");
const fs = require("fs");
const path = require("path");

module.exports = async({getNamedAccounts,deployments}) =>{
    //获取配置的地址
    const {deployer} = await getNamedAccounts();

    //获取部署需要的变量
    const {deploy,log}  = deployments;
    log("deploying nft contract")

    const de = await deploy("MyERC721",{
        contract: "MyERC721",
        from: deployer,
        log: true,
        args: []
    })

    log("部署人地址:",deployer)

    // const nft = await ethers.getContractFactory("MyToken");
    // const nftContract = await nft.deploy("MYTOKEN","MTY");
    // await nftContract.deployed();
    const myNFT = await deployments.get("MyERC721");
    //生成abi,bin文件
    //拼接存储路径
      const erc721ABI = path.resolve(__dirname,"../address/erc721.abi")
      fs.writeFileSync(
        erc721ABI,
        JSON.stringify(myNFT.abi, null, 2)
      )

      const erc721BIN = path.resolve(__dirname,"../address/erc721.bin")
      fs.writeFileSync(
        erc721BIN,
        myNFT.bytecode
      )
    
    log("nft deployed")
}
module.exports.tags = ['MyERC721Deploy'];