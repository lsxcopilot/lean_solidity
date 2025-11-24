# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
#安装remixd 与 remixd共享开发文件
npm install -g @remix-project/remixd
npx remixd

#可升级需要安装的库
npm install @openzeppelin/contracts-upgradeable
npm install @openzeppelin/hardhat-upgrades
```
