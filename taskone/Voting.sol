// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Voting{
    //记录所有候选人
    string[] names;

    //一个mapping来存储候选人的得票数
    mapping (string => uint256) votes;

    //一个vote函数，允许用户投票给某个候选人
    function vote (string memory name) external {
        if (votes[name]==0){
            names.push(name);
        }
       votes[name]++;
    }
    //一个getVotes函数，返回某个候选人的得票数

    function getVotes(string memory name) external view  returns (uint256 num){
        return votes[name];
    }

    //一个resetVotes函数，重置所有候选人的得票数
    function resetVotes() external {
        uint256 len = names.length;
        for (uint256 i = 0; i<len; i++) 
        {
            votes[names[i]] = 0;
        }
    }
}