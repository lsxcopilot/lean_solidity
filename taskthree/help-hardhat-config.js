const DECIMAL = 8
const INITIAL_ANSWER = 300000000000
const deployMentChains = ["hardhat","local"]
const networkConfig = {
    11155111:{
        ethUsdDataFeed: "0x694AA1769357215DE4FAC081bf1f309aDC325306",
        usdcUsdDataFeed: "0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E"
    }
}
module.exports = {
    DECIMAL,
    INITIAL_ANSWER,
    deployMentChains,
    networkConfig
}