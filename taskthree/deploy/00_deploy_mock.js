const { deployments,ethers } = require("hardhat")
const { DECIMAL,INITIAL_ANSWER } = require("../help-hardhat-config")

module.exports=async ({getNamedAccounts,deployments}) =>{

    const {deployer} = await getNamedAccounts();
    
     //获取部署需要的变量
    const {deploy}  = deployments;

    await deploy("MockV3Aggregator",{
        contract:"MockV3Aggregator",
        from: deployer,
        args:[DECIMAL,INITIAL_ANSWER],//假定1eth = 3000美元，换算下来就是3000*10**8
        log: true
    })
}

module.exports.tags=['all','mock'];