// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//实现openzeppelin下的NFT的标准接口ERC721
//创建一个简单的 NFT 铸造系统，允许用户为任何地址创建带有自定义元数据的唯一数字收藏品。
contract TestERC721 is ERC721{
    string private _baseTokenURI;

    // 使用 OpenZeppelin 的计数器库来管理 token ID
    /*
        Counters.Counter 原本只是一个简单的计数器
        using Counters for Counters.Counter 给这个计数器添加了三个便捷方法：

        .increment() - 计数器+1
        .decrement() - 计数器-1
        .current() - 获取当前值
    */
    using Counters for Counters.Counter;

    // 声明一个私有的计数器变量来跟踪当前的 token ID
    Counters.Counter private _tokenIds;

    //存储tokenURL与id的映射关系
    mapping (uint256 => string) public _tokenURIs;

    //编写构造函数，初始化ERC721
    constructor (string memory baseURI) ERC721("MyNFT","MNFT"){
        _baseTokenURI = baseURI;
    }
    //铸币
    //给对应的地址用户，添加凭证链接（IPFS元数据连接） 
    function mintNFT(address recipient,string memory tokenURI)  public returns (uint256){
        // 增加 token ID 计数器
        _tokenIds.increment();

        // 获取新的 token ID
        uint256 newItemId = _tokenIds.current();

        // 铸造 NFT：将新 token 分配给接收者地址
        _mint(recipient, newItemId);

        // 设置该 token 的元数据 URI（比如指向 IPFS 的 JSON 文件）
        _setTokenURI(newItemId, tokenURI);
        // 自动使用 _baseURI() + tokenId 作为 tokenURI

        // 返回新创建的 token ID
        return newItemId;
    }

     function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

     function _setTokenURI(uint256 id, string memory _tokenURL) internal{
        _tokenURIs[id] = _tokenURL;
     }
}