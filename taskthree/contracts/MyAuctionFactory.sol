// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "./MyAuctionUp.sol";

contract MyAuctionFactory {
    //存储已经创建的拍卖会
    address[] public auctionUps;

    //填充tokenId与拍卖会的映射关系
    mapping(uint256 => MyAuctionUp) public auctionsMap;

    //创建拍卖会
    function createAuction(
            uint256 startPrice,
            uint256 duringTime,
            uint256 tokenId,
            address nftContractAddress
        ) external returns(address){
            MyAuctionUp ma = new MyAuctionUp();
            ma.createAuction(startPrice, duringTime,tokenId,nftContractAddress);
            //存放到拍卖会集合中
            auctionUps.push(address(ma));
            //建立拍卖会映射
            auctionsMap[tokenId] = ma;
            //返回创建的拍卖会地址
            return address(ma);
        }

    //获取已经创建的拍卖会
    function getAuctions() external view returns (address[] memory) {
        return auctionUps;
    }

    //根据indexId获取拍卖会
    function getAuction(uint256 tokenId) external view returns (address) {
        return address(auctionsMap[tokenId]);
    }


}