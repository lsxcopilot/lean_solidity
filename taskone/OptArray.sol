// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract OptArray{
    
    function mergeArray(uint256[] memory a,uint256[] memory b) external pure  returns(uint256[] memory c) {
        
        uint256 len = a.length + b.length;
        uint256[] memory result = new uint256[](len);
        //存储位置
        uint256 posA = 0;
        uint256 posB = 0;
        uint256 i = 0;
            
            while( posA<a.length && posB<b.length){
                if (a[posA]<=b[posB]){
                    result[i] = a[posA];
                    posA++;
                    i++;
                }else{
                    result[i] = b[posB];
                    posB++;
                    i++;
                }
            }

            //处理a的剩余元素
            while (posA<a.length){
                result[i] = a[posA];
                posA++;
                i++;
            }

            //处理b的剩余元素
            while (posB<b.length){
                result[i] = b[posB];
                posB++;
                i++;
            }
        
        return result;
    }
}