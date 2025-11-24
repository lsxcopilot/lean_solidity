//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
//可升级合约
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NftAuctionV2 is Initializable{
    struct Auction{
        //拍卖者
        address seller;
        //起拍价
        uint256 startingPrice;
       
        //拍卖是否结束
        bool ended;

        //拍卖持续时间
        uint256 duration;

        //拍卖开始时间
        uint256 startTime;

         //最高出价
        uint256 highestBid;
        //最高出价者
        address highestBidder;

        //nft的合约地址
        address nftContract;
        //nft的id
        uint256 tokenId;
    }

    //定义拍卖的映射关系
    mapping(uint256=>Auction) public auctions;
    //下一个拍卖的id
    uint256 public nextAuctionId;

    //管理员id
    address public admin;

    // Contract code goes here
    function initializable() public initializer {
        admin = msg.sender;
    }

    //创建拍卖
    function createAuction(uint256 _startingPrice,uint256 _duration,address _nftContract,uint256 _tokeId) external {
        //只有管理员可以创建拍卖
        require(msg.sender == admin,"Only admin can create auction");
        //持续时间大于零
        require(_duration > 0,"Duration must be greater than zero");
        //初始价格大于零
        require(_startingPrice > 0,"Starting price must be greater than zero");

        //转移NFT给当前合约
        IERC721(_nftContract).approve(address(this), _tokeId);

        //创建拍卖
        auctions[nextAuctionId] = Auction(
            msg.sender,
            _startingPrice,
            false,
            _duration * 1000 * 60,
            block.timestamp,
            0,
            address(0),
            _nftContract,
            _tokeId
        );
        nextAuctionId++;
        }

    //买家参与买单
    function bid(uint256 _auctionId) external payable {
        //获取拍卖信息
        Auction storage auction = auctions[_auctionId];
        //检查拍卖是否结束
        require(auction.ended && block.timestamp < auction.startTime + auction.duration,"Auction already ended");
        
        //出价是否高于当前最高出价
        require(msg.value > auction.highestBid && msg.value >= auction.startingPrice,"Bid not high enough");

        //退还之前的最高出价
        if(auction.highestBidder != address(0)){
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        //更新最高出价和最高出价者
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
    }

    //结束拍卖
    function endAuction(uint256 _auctionId) external {
        //获取拍卖信息
        Auction storage auction = auctions[_auctionId];
        //检查拍卖是否结束
        require(!auction.ended && block.timestamp >= auction.startTime + auction.duration,"Auction not yet ended"); 
        //标记拍卖结束
        auction.ended = true;
        //将NFT转移给最高出价者
        IERC721(auction.nftContract).transferFrom(address(this), auction.highestBidder, auction.tokenId);
        //将最高出价转移给卖家
        payable(address(this)).transfer(auction.highestBid);
        }

    function sayHello() public pure returns(string memory){
        return "Hello,world!";
    }
}