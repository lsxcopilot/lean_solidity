// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/*
二分查找 (Binary Search)
题目描述：在一个有序数组中查找目标值。
*/
contract BinarySearch{
    function BinaryFind(uint256[] memory arr,uint256 findValue) external pure returns (uint256 result){
        //存储位置信息
        uint256 posLeft;
        uint256 posRight = arr.length-1;
        uint256 posMiddle = (posLeft+posRight)/2;

        while (true){
            //能找到
            if (arr[posMiddle] == findValue){
                return arr[posMiddle];
            }else{
                 if (findValue<arr[posMiddle]){
                    posRight = posMiddle;
                    posMiddle = (posLeft+posRight)/2;
                 }

                if (findValue>arr[posMiddle]){
                    posLeft = posMiddle;
                    posMiddle = (posLeft+posRight)/2;
                }
            }

            if (arr[posRight] == findValue){
                return arr[posRight];
            }

            if (arr[posLeft] == findValue){
                return arr[posLeft];
            }
            //不能找到
            if ((posLeft==posLeft) || (posLeft - posLeft == 1)){
                return 0;
            }
        }

    }
}