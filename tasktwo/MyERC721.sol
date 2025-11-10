// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721 is ERC721 {
    
    //1.给Counters.Counter添加增强函数
    using Counters for Counters.Counter;

    //2. 创建一个计数器
    Counters.Counter private _tokenIds;

    //设置最大限制
    uint256 MAX_NUM = 1000;

    //存放tokenId对应的uri
    mapping ( uint256 => string ) public tokenIdToUri;
   

    //设置基础路由(IPFS:https://ipfs.io/ipfs/)
    //0xfE1d3b475B9C0072681deC2De6b36EA83A5edfc6,https://ipfs.io/ipfs/bafkreid6b6xpe36wiff2rzzfps6fqoubh6zeqpeiga7xeshhp3ckbgyqsq
    //0xfE1d3b475B9C0072681deC2De6b36EA83A5edfc6,https://ipfs.io/ipfs/bafkreid6b6xpe36wiff2rzzfps6fqoubh6zeqpeiga7xeshhp3ckbgyqsq
    //0xfE1d3b475B9C0072681deC2De6b36EA83A5edfc6,https://ipfs.io/ipfs/bafkreidxsbsckhx5roi4fejqpwk2neddrrfs5t6p26xpwwrqlcigre4z2q
    //string baseUrl;

    //定义事件
    event MintNFT(address to,uint256 tokenId,string uri);

    //3. 创建一个构造函数，初始化父类的构造函数
    constructor()ERC721("MYFIRSTNFT","MYNFT"){}
    

    //4.铸币函数
    function mintNFT(address to,string memory uri) public returns(uint256){
        require(to!=address(0),"to address is not zero address");
        require(_tokenIds.current()<=MAX_NUM,"more than max number");
        //每次铸造，代表发行量加一
        _tokenIds.increment();
        //获取当前id
        uint256 newTokenId = _tokenIds.current();
         _safeMint(to, newTokenId);
        setTokenIdToUri(newTokenId, uri);

        //记录日志信息
        emit MintNFT(to,newTokenId,uri);
        return newTokenId;
    }

    //设置自定义关系
    function setTokenIdToUri(uint256 tokenId,string memory uri) internal {
        tokenIdToUri[tokenId] = uri;
    }

    // 重写 tokenURI 函数
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return tokenIdToUri[tokenId];
    }
}