// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract BeggingContract{
    address owner;

    //每个捐赠者捐赠金额
    mapping(address => uint256) balances;
    //总金额,合约中默认的单位是wei 
    //1个ETH = 10的18次方wei
    //1个finney = 10的15次方wei
    //1个gwei = 10的9次方wei
    uint256 totalBalance;

    constructor(){
        owner = msg.sender;
    }

    //校验合约所有者
    modifier ownerCheak(){
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    //允许用户向合约转账
    function donate(uint256 amount) external payable{
        require(amount>0,"amount must be than zero");
        //记录添加金额
        balances[msg.sender]= balances[msg.sender]+msg.value;
        totalBalance += msg.value;
    }

    //允许合约所有者提取金额
    function withdraw() external payable ownerCheak{
        require(totalBalance>0,"not enougt amount");
        totalBalance = 0;
        payable(msg.sender).transfer(totalBalance);
    }

    //允许查询某个地址的捐赠金额
    function getDonation(address getBalance) view external returns (uint256){
        return balances[getBalance];
    }
}