const { ethers,deployments,upgrades } = require("hardhat")//引入运行时环境


//测试用例
describe("test upgradle",async ()=>{
    //引入断言库，做测试判断
    const {expect} = require("chai");
   
    //编写测试用例
    it("测试合约升级",async ()=>{
        //1.部署合约
            //执行标签为 "NftAuction" 的所有部署脚本。这里指的是01_deploy_nft_auction.js脚本
            await deployments.fixture(["NftAuction"]);
            //获取合约真实地址
            await upgrades.erc1967.getImplementationAddress;
            //执行标签为 "NftAuctionProxy" 的所有部署脚本。这里指的是02_upgrade_nft_auction.js脚本
            const NftAuctionProxy = deployments.get("NftAuctionProxy");
        //2.调用createAuction函数，创建拍卖
            //创建NftAuction 的代理合约
            const nftAuction = await ethers.getContractAt("NftAuction", (await NftAuctionProxy).address);
            await nftAuction.createAuction(
                ethers.parseEther("0.001"), 
                120,
                ethers.ZeroAddress,
                1
            );
            const auction1 = await nftAuction.auctions(0)
            console.log("创建拍卖成功",auction1)
        //3.升级合约
            await deployments.fixture(["UpgradeNftAuction"]);
        //4.读取合约的actions(0),如果actions(0)存在，说明数据没有丢失,合约升级成功
            const nftAuctionV2 = await ethers.getContractAt("NftAuctionV2", (await NftAuctionProxy).address);
            const auction2 = await nftAuctionV2.auctions(0);
            expect(auction1.startTime).to.equal(auction2.startTime);
            
            const result = nftAuctionV2.sayHello();
            console.log("合约升级成功，拍卖数据未丢失",auction2,"sayHello:",result);
    })

})