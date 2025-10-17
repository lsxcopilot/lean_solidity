// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
//理解receive的触发机制，使用场景
contract receiveTest{
    //接收eth数量
    uint256 public receiveAccount;
    //合约用所属者
    address public owner;
    //调用位置
    string public position;
    //参数data
    bytes public lastdate;

    //事件函数，记录日志
    event Log(string message, address sender,uint256 value,bytes data);

    constructor(){
        owner = msg.sender;
    }

    //receive函数
    /*
    调用时机：当交易包含以太币（msg.value > 0）且没有data时调用
    必需声明：receive() external payable
    */
    //只处理纯ETH转账
    receive() external payable { 
        receiveAccount += msg.value;
        position = "receive postition";
        emit Log(position, msg.sender, msg.value, "");
    }

    //一般函数,msg.value只能用于payable 修饰的函数
    function normalFunction() public payable  {
        receiveAccount += msg.value;
        position = "normalFunction position";
        emit Log(position, msg.sender, msg.value, "");
    }

    //fallback函数
    /*
    调用时机：
        当交易包含以太币（msg.value > 0）且有data时调用
        当交易不包含以太币（msg.value = 0）且没有匹配的函数签名时调用
    声明方式：
        fallback() external payable 或 
        fallback(bytes calldata input) external returns (bytes memory output)
    */
    //处理带数据的ETH转账或未知函数调用
    fallback() external payable {
        receiveAccount += msg.value;
        position = "fallback";
        lastdate = msg.data;
        emit  Log(position, msg.sender, msg.value, lastdate);
    }
    //查询合约余额
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    //重置状态
    function reset() public {
        receiveAccount = 0;
        position = "";
        lastdate = "";
    }
}

contract testReceive{
    //触发receive函数
    function withOutDataSendETH(address payable demo) public payable {
        //使用call方式调用
        (bool success, ) = demo.call{value: msg.value}("");
        require(success,"Transfer faild");
    }

    //触发fallback函数，调用未知函数切没有ETH
    function sendZeroETH(address payable demo) external payable {
        //使用call方式调用
        (bool success,) = demo.call(abi.encodeWithSignature("noFunction()"));
        require(success,"Transfer faild");
    }

    //触发fallback函数，发送data且有ETH
    function withDataSendETH(address payable demo) external payable {
       (bool success, ) = demo.call{value:msg.value}("noFunction");
       require(success,"Transfer faild");
    }

    //触发普通函数
    function testCallNormalFunction(address payable demo) external payable {
        (bool success, ) = demo.call{value:msg.value}(abi.encodeWithSignature("normalFunction()"));
        require(success,"normal function faild");
    }
}