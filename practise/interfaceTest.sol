// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
//定义银行接口
interface IBank {
    //押金
    function deposit() external payable; 
    //撤回
    function withdraw(uint256 amount) external returns (bool);
    //获取当前金额
    function getBalance() external view returns (uint256);
}
//定义合约实现银行接口，实现了接口就需要实现接口中的所有方法
contract Bank is IBank{

    mapping (address => uint256) public contrctMapping;
    //提交押金
    function deposit() external payable override {
        require(msg.value>10,"your balance must more than zero");
        contrctMapping[msg.sender]+=msg.value;
    }

    //撤回金额
    function withdraw(uint256 amount) external override returns (bool){
        require(contrctMapping[msg.sender]>=amount,"your balance is not enough");
        //防重入攻击
        contrctMapping[msg.sender]-=amount;
         // 使用 send 代替 transfer，它有返回值可以处理
        payable(msg.sender).transfer(amount);
        return true;
    }

    function getBalance() external view override returns (uint256){
        return contrctMapping[msg.sender];
    }
}

//定义合约使用银行接口
contract UBank{
    //调用接口函数-押金
    //payable修饰时无法再使用view修饰
    /*
    问题：view 和 payable 是互斥的状态可变性修饰符：
         view - 表示函数只读取状态，不修改状态，也不接收以太币
         payable - 表示函数可以接收以太币，通常会修改状态
    */
    //因为是Bank合约实现了IBank接口，所以如果要调用Bank合约的接口实现方法，ubankAddress应该传Bank合约的地址
    function ubankDeposit(address ubankAddress) external payable{
        IBank ibank = IBank(ubankAddress);
        //发送ETH
        ibank.deposit{value:msg.value}();
    } 

    function ubankWithdraw(address ubankAddress,uint256 amount) external {
       IBank ibank =  IBank(ubankAddress);
       ibank.withdraw(amount);
    }

    //在调用外部函数中，即使接口声明为了view只读，但是依然有可能改变状态
    function getBanlance(address ubankAddress) external view returns (uint256){
        IBank ibank =  IBank(ubankAddress);
        return ibank.getBalance();
    }
}





