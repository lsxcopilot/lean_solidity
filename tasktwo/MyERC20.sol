// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MyERC20{
    //合约所有者
    address owner;

    //发行代币总量
    uint256 totalSupply;

    //初始代币量
    uint256 initSupply;


    //记录账户余额
    mapping (address => uint256) myBalances;

    //记录代理授权及代扣金额上限
    mapping (address => mapping (address => uint256)) myAuthorizedAgent;

    //添加对应事件

    constructor(uint256 _initSupply){
        owner = msg.sender;
        if (_initSupply>0){
            totalSupply = _initSupply;
            initSupply = _initSupply;
            myBalances[owner] = _initSupply;
        }
    }

    //查询账户余额
    function balanceOf() external view returns (uint256){
        return myBalances[msg.sender];
    }

    //授权,并给出代扣上限
    function approve(address from,address to, uint256 _value) external returns (bool){
        require(from!=address(0) && to!=address(0),"address can not is zero");
        require(_value>0,"amount must be more than zero");
        myAuthorizedAgent[from][to] = _value;
        return true;
    }

    //代扣转账
    function transferFrom(address from,address to, uint256 _value) external returns (bool){
        require(from!=address(0) && to!=address(0),"address can not is zero");
        require(_value>0,"amount must be more than zero");
        require(myBalances[from]>=_value,"balance is not enough");
        require(myAuthorizedAgent[from][msg.sender]>=_value,"authorized amount is not enough");

        //扣除代扣上限
        myAuthorizedAgent[from][msg.sender] -= _value;
        //扣除账户余额
        myBalances[from] -= _value;
        //增加账户余额
        myBalances[to] += _value;
        return true;
    }
    //普通转账
    function transfer(address to, uint256 _value) external returns (bool){
        require(to!=address(0),"address can not is zero");
        require(_value>0,"amount must be more than zero");
        require(myBalances[msg.sender]>=_value,"balance is not enough");
        //扣除账户余额
        myBalances[msg.sender] -= _value;
        //增加账户余额
        myBalances[to] += _value;
        return true;
        }

}