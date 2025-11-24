// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ReverseString{
    //题目描述：反转一个字符串。输入 "abcde"，输出 "edcba"
    function ReverseStr(string memory input) external pure returns (string memory){
            bytes memory arr = bytes(input);
            uint256 len = arr.length;
            bytes memory result = new bytes(len);
            for (uint256 i = 0; i<len; i++) 
            {
                result[i] = arr[len-1-i];
            }
            return string(result);
    }
}