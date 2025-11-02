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

    //记录开始时间,为合约部署时间（时间是用秒为单位记录的）
    uint256 startTime = block.timestamp;
    //记录金额持续时间
    uint during;

    //排行榜,记录金额捐赠前三的donor
    address[3] public rankingList;
   

    constructor(uint256 _during){
        owner = msg.sender;
        during = _during;
    }

    //校验合约所有者
    modifier ownerCheak(){
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    //校验时间窗口是否关闭
    modifier windonCloseCheak(){
        require(block.timestamp <= startTime + during, "window is closed");
        _;
    }


    //添加捐赠事件
    event DonationReceived(address donor, uint256 amount);

    //允许用户向合约转账
    function donate(uint256 amount) external payable windonCloseCheak{
        require(amount>0,"amount must be than zero");
        
        //记录添加金额
        balances[msg.sender] = balances[msg.sender]+msg.value;
        totalBalance += msg.value;
        //更新记录排行榜
        updateRankingList();
        //记录事件
        emit DonationReceived(msg.sender, amount);
    }

    //允许合约所有者提取金额,要求时间窗口关闭以后才能提取金额
    function withdraw() external payable ownerCheak{
        require(block.timestamp > startTime + during, "window is not closed");
        require(totalBalance>0,"not enougt amount");
        totalBalance = 0;
        payable(msg.sender).transfer(totalBalance);
    }

    //允许查询某个地址的捐赠金额
    function getDonation(address getBalance) view external returns (uint256){
        return balances[getBalance];
    }

    //更新排行榜
    function updateRankingList() internal {
        uint256 len = rankingList.length;
        address temp;
        for (uint256 i = 0; i<len; i++) 
        {
            //如果捐赠者的金额大于等于前三中的一个则进行地址更新
            if(balances[msg.sender]>balances[rankingList[i]]){
                temp = rankingList[i];
                rankingList[i] = msg.sender;
                if (i+1<len){
                    rankingList[i+1] = temp;
                } 
                break;
            }
        }
    }
}