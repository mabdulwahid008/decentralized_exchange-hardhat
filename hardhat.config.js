// require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-waffle");
require("dotenv").config()

module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli : {
      url: process.env.URL,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
