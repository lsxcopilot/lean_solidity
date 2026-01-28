const { deployments,getNamedAccounts } = require("hardhat");

module.exports = async({getNamedAccounts,deployments}) =>{
    //获取配置的地址
    const {deployer} = await getNamedAccounts();

    //获取部署需要的变量
    const {deploy,log}  = deployments;
    log("deploying nft contract")

    await deploy("MyAuctionUp",{
        contract: "MyAuctionUp",
        from: deployer,
        log: true,
        args: []
    })

    log("部署人地址:",deployer)

    // const nft = await ethers.getContractFactory("MyToken");
    // const nftContract = await nft.deploy("MYTOKEN","MTY");
    // await nftContract.waitForDeployment();
    
    log("nft deployed")
}
module.exports.tags = ['MyAuctionDeploy'];