
const { ethers,deployments, network} = require("hardhat");
const { deployMentChains,networkConfig } = require("../help-hardhat-config")
//引入helper模拟时间流失
const  helper  = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

//编写测试内容
describe("contact up",async function(){
    beforeEach(async function(){
        //1.部署合约,执行deploy的脚本文件
        await deployments.fixture(["MyAuctionDeploy","mock"]);
        //从save中提取代理合约地址
        const proxyAddress = await deployments.get("NFTContrctproxy");
        
        console.log("开始创建代理客户端", proxyAddress.address)
        //通过代理地址获取合约客户端
        myAuctionUp = await ethers.getContractAt("MyAuctionUp", proxyAddress.address);
        //获取MYNFT的合约
        const myNFT = await deployments.get("MyERC721");
        myNFTContrct =  await ethers.getContractAt("MyERC721",myNFT.address);
        //进行NFT的授权
        const app = await myNFTContrct.approve(proxyAddress.address,0)
        await app.wait();

         //2.创建拍卖
       await myAuctionUp.createAuction(
            ethers.parseEther("0.01"),
            86400,
            0,
            myNFT.address
        )
        const befer =  await myAuctionUp.auctionMapping(0)
        console.log("创建拍卖成功,拍卖开始时间：",befer.startTime)
    })

    it("测试合约是否升级成功",async function() {
        //3.升级合约
        await deployments.fixture(["upNFTContractProxy"])
        //从save中读取代理合约地址
        const proxyUpAddress = await deployments.get("proxyV2");
        //获取升级后的代理实例
        const v2ProxyAddress = await proxyUpAddress.address;
        afterUpContract =  await ethers.getContractAt("MyAuctionV2",v2ProxyAddress);
        //4.对比升级后的合约的状态变量是否保存了升级前的信息auction[0]
        const after = await afterUpContract.auctionMapping(0)
        console.log("升级后的状态变量数据：",after)
        console.log("升级后的startTime",after.startTime)
    });
})

describe("start contract",async function(){
    // 增加超时时间到 120 秒
    this.timeout(120000);
    let myAuctionUp
    let myNFTContrct
    let price = ethers.parseEther("0.03")
    let auctionMapping
    //每次执行it都需要先执行beforeEach保证每个it的测试隔离性
    before(async function(){
        //1.部署合约,执行deploy的脚本文件
        await deployments.fixture(["MyAuctionDeploy","mock"]);
        //从save中提取代理合约地址
        const proxyAddress = await deployments.get("NFTContrctproxy");
        
        console.log("开始创建代理客户端", proxyAddress.address)
        //通过代理地址获取合约客户端
        myAuctionUp = await ethers.getContractAt("MyAuctionUp", proxyAddress.address);
        //获取MYNFT的合约
        const myNFT = await deployments.get("MyERC721");
        myNFTContrct =  await ethers.getContractAt("MyERC721",myNFT.address);
        //进行NFT的授权
        const app = await myNFTContrct.approve(proxyAddress.address,0)
        await app.wait();

         //2.创建拍卖
       await myAuctionUp.createAuction(
            ethers.parseEther("0.01"),
            86400,
            0,
            myNFT.address
        )
        const befer =  await myAuctionUp.auctionMapping(0)
        console.log("创建拍卖成功,拍卖开始时间：",befer.startTime)
    })

    it("测试竞拍函数",async function(){
        //使用两个用户调用竞拍函数
        const {user1,user2} = await getNamedAccounts();
        console.log("用户user1",user1)
        console.log("用户user2",user2)
        console.log("-----------设置喂价------------")
        //设置喂价的地址：竞拍代币(0:ETH, other:ERC20)
        let setONE ="";
        if(deployMentChains.includes(network.name)){
            const mock = await deployments.get("MockV3Aggregator");
            setONE = await myAuctionUp.setTokenPriceFeed(ethers.ZeroAddress,mock.address);
        }else{
            setONE = await myAuctionUp.setTokenPriceFeed(ethers.ZeroAddress,networkConfig[network.config.chainId].ethUsdDataFeed);
        }
        await setONE.wait();
        console.log("-----------设置喂价结束------------")
        auctionMapping = await myAuctionUp.auctionMapping(0);
        // 获取最新区块
        const block = await ethers.provider.getBlock("latest");
        const currentTimestamp = block.timestamp;

        console.log("开始时间",auctionMapping.startTime)
        console.log("持续时间",auctionMapping.duringTime)
        console.log("是否结束：",auctionMapping.ended)
        console.log("是否在拍卖会期间：",currentTimestamp<(auctionMapping.startTime+auctionMapping.duringTime))
        
        //竞拍
        console.log("-----------竞价开始------------")
        try {
            console.log("拍卖会初始价格：",auctionMapping.startingPrice);
            console.log("出价价格：",ethers.parseEther("0.03"));
            console.log("是否大于初始价格",ethers.parseEther("0.03")>auctionMapping.startingPrice);
            await myAuctionUp.bid(0,ethers.parseEther("0.03"),ethers.ZeroAddress,{
                value: price
            });
        } catch (error) {
            console.error("❌失败:",error);
            console.error("错误信息:", error.message);
        }
        console.log("-----------竞价结束------------") 
        //需要重新获取，拿取结构体中的新的值  
        auctionMapping = await myAuctionUp.auctionMapping(0); 
        console.log("目前合约的最高出价：",auctionMapping.highestBid)
        console.log("目前合约的最高出价者：",auctionMapping.highestBidder)
    });

    it("测试拍卖结束函数",async function(){
        auctionMapping = await myAuctionUp.auctionMapping(0);
        const aucBegin = auctionMapping.seller;
        const aucBeginValue = await ethers.provider.getBalance(aucBegin);
        console.log("获取账户余额：",aucBeginValue);
        //设置时间增加180秒
        await helper.time.increase(86500);
        //模拟挖矿,时间流逝200秒
        await helper.mine();
        // 获取最新区块
        const block = await ethers.provider.getBlock("latest");
        const currentTimestamp = block.timestamp;
        
        console.log("开始时间",auctionMapping.startTime)
        console.log("持续时间",auctionMapping.duringTime)
        console.log("当前时间",currentTimestamp)
        console.log("当前拍卖会是否结束：",currentTimestamp>=(auctionMapping.startTime+auctionMapping.duringTime))
        console.log("当前出价最高者",auctionMapping.highestBidder)
        console.log("当前出价最高金额",auctionMapping.highestBid)
        //调用合约结束按钮
        console.log("拍卖结束开始");
        await myAuctionUp.endAuction(0);
        console.log("拍卖结束结束");
        
        //查看NFT的拥有者是否是最高出价者
        const ownerNFTAddress = await myNFTContrct.ownerOf(0);
        expect(ownerNFTAddress).to.equal(auctionMapping.highestBidder).revertedWith("拥有者不一致")
        
        //查看卖家是否收到货款
        const value = auctionMapping.highestBid;
        const auc = auctionMapping.seller;
        const aucValue = await ethers.provider.getBalance(auc);
        
        console.log("获取账户余额：",aucValue);
        console.log("账户差额：",aucValue-aucBeginValue);
        expect(price).to.equal(value).revertedWith("价格不一致")
         console.log("测试拍卖结束函数");
    });
})