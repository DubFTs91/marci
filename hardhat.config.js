require("@nomiclabs/hardhat-waffle");
const fs = require("fs")
// fs.readFileSync(".secret").toString()


module.exports = {
  networks: {
    //hardhat default for local testing
    hardhat: {
      chainId: 1337
    },
    // mumbai is the test polygon network. tie with your infura
    mumbai: {
      url: 'https://polygon-mumbai.infura.io/v3/${process.env.PROJECTID]}',
      accounts: [fs.readFileSync(".secret").toString()]
    },
    // mainnet is the real polygon network. tie with your infura
    mainnet: {
      url: 'https://polygon-mainnet.infura.io/v3/{process.env.PROJECTID]}',
      accounts: [fs.readFileSync(".secret").toString()]
    }
  },
  solidity: "0.8.4",
};


