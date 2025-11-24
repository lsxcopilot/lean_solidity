// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//使用Chainlink价格预言机接口
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//0x694AA1769357215DE4FAC081bf1f309aDC325306 ETH/USD 测试网地址
//0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E USDC/USD 测试网地址

contract MyAuction {

    //拍卖管理员
    address auctionAdmin;
    //拍卖映射
    mapping(uint256 => Auction) public auctionMapping;
    //拍卖会ID
    uint256 public auctionId;

    //定义拍卖结构体
    struct Auction{
        //卖家
        address seller;
        //起拍价
        uint256 startingPrice;
        //最高出价
        uint256 highestBid;
        //最高出价者
        address highestBidder;
        //拍卖持续时间
        uint256 duringTime;
         //拍卖开始时间
        uint256 startTime;
        //拍卖是否结束
        bool ended;
        //竞拍代币(0:ETH, other:ERC20)
        address tokenAddress;
        //NFT ID
        uint256 tokenId;
        //NFT address
        address nftAddress;
    }

    //引入喂价变量
    AggregatorV3Interface internal priceFeed;

    //代币地址与喂价映射
    mapping(address => AggregatorV3Interface) public tokenPriceFeedMapping;

    function setTokenPriceFeed(address _tokenAddress, address _priceFeed) public {
        require(msg.sender == auctionAdmin, "Only admin can set price feed");
        tokenPriceFeedMapping[_tokenAddress] = AggregatorV3Interface(_priceFeed);
    }

    //获取对应代币相对于美元的最新价格
    function getLatestPrice(address _tokenAddress) public  returns (int256) {
        priceFeed = tokenPriceFeedMapping[_tokenAddress];
        (
            ,
            int256 price,
            ,
            ,
        ) = priceFeed.latestRoundData();
        return price;
    }

    constructor(address _admin) {
        //设置拍卖管理员
        auctionAdmin = _admin;  
    }

    //拍卖创建函数
    function createAuction(uint256 startingPrice,uint256 duringTime,address _nftAddress,uint256 tokenId) public {
        require(auctionMapping[auctionId].seller != address(0), "seller address is zero");
        auctionMapping[auctionId] = Auction({
            seller: msg.sender,
            startingPrice: startingPrice,
            highestBid: 0,
            highestBidder: address(0),
            duringTime: duringTime,
            ended: false,
            startTime: block.timestamp,
            tokenAddress: address(0),
            tokenId:tokenId,
            nftAddress: _nftAddress
        });
        auctionId++;
        //将NFT转移到当前合约
        IERC721(_nftAddress).safeTransferFrom(msg.sender, address(this), tokenId);
    } 

    //竞拍函数
        //统一的价值尺度 一般是八位小数：
            //ETH 多少 USD  340807710200  ： 1ETH = 3408.07710200 USD
            //USDC 多少 USD  99983000 : 1ERC20(USDC) = 0.99983000 USD
    function bid(uint256 _auctionId, uint256 _bidAmount,address _tokenAddress) public payable{
        //1.判断当前是否在拍卖时间内,且拍卖没有结束
        Auction storage auction = auctionMapping[_auctionId];
        require(block.timestamp < auction.startTime + auction.duringTime && auction.ended, "Auction has ended");
        //2.判断出价是否高于起拍价和当前最高价
        uint256 payValue;
        if(_tokenAddress != address(0)){
            payValue = (_bidAmount * uint256( getLatestPrice(_tokenAddress))) / 1e8;
        }else{
             _bidAmount = msg.value;
             payValue =  (_bidAmount * uint256( getLatestPrice(address(0)))) / 1e8;
        }

        //需要统一转换成美元进行比较
                //计算起拍价对应的美元价值
                uint256 startingPriceInUSD = (auction.startingPrice * uint256(getLatestPrice(_tokenAddress))) / 1e8;
                //计算当前最高价对应的美元价值
                uint256 highestBidInUSD = (auction.highestBid * uint256(getLatestPrice(_tokenAddress))) / 1e8;
                //满足出价要求，替换出价
                require(payValue >= startingPriceInUSD && payValue > highestBidInUSD, "Bid amount is too low");
               
                    //如果之前的最高价是ETH
                    if(auction.tokenAddress == address(0)){
                        payable(auction.highestBidder).transfer(auction.highestBid);
                        //将价值写入合约
                        payable(address(this)).transfer(msg.value);
                    }else{
                        //如果之前最高价是ERC20:从当前合约转移给出价最高的人
                        IERC20(_tokenAddress).transferFrom(address(this), auction.highestBidder, _bidAmount);
                        //将代币转移到合约
                        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _bidAmount);
                    }

        //替换出价的最高拍卖者
        auction.highestBid = _bidAmount;
        auction.highestBidder = msg.sender;

        //将最高出价给到合约
        payable(address(this)).transfer(_bidAmount);
    }
       
        
    //拍卖结束函数
    function endAuction(uint256 _auctionId) public  {
        Auction storage auction = auctionMapping[_auctionId];
        
        //1.判断拍卖是否已经结束
        require(block.timestamp >= auction.startTime + auction.duringTime && auction.ended, "Auction is still ongoing");

        //2.将拍卖品转移给最高出价者
        IERC721(auction.nftAddress).safeTransferFrom(address(this), auction.highestBidder, auction.tokenId);

        //3.将最高出价转移给卖家
        if(auction.tokenAddress==address(0)){
            payable(auction.seller).transfer(address(this).balance);
        }else{
            IERC20(auction.tokenAddress).transfer(auction.seller, auction.highestBid);
        }
        
    }


}