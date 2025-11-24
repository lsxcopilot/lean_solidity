// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyERC721 is ERC721{

    uint256 public nextTokenId;

    mapping(uint256 => string) mappingTokenURI;
    
    constructor() ERC721("MYNFT","MNFT"){}

    function mintNFT(address to,string memory uri) public {

        _safeMint(to, nextTokenId);
        mappingTokenURI[nextTokenId] = uri;
        nextTokenId++;
    }

    // 重写 tokenURI 函数
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return mappingTokenURI[tokenId];
    }



}