import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
    etherscan: {
      apiKey: {
        bscTestnet: "Q6VCHDYPPATQHPS4CR3AUUQ41ARAMSXZA4",
      },
    customChains: [
    {
      network: "bscTestnet",
      chainId: 97,
      urls: {
        apiURL: "https://api.etherscan.io/v2/api?chainid=97&apikey=Q6VCHDYPPATQHPS4CR3AUUQ41ARAMSXZA4",
        browserURL: "https://testnet.bscscan.com/"
      }
    },]
    },
    networks: {
      BscTestnet: {
        url: "https://data-seed-prebsc-2-s1.binance.org:8545/",
        accounts: ['a6a6cbe826ae0753ea6652869340b06224430e7558bae1637d384418cd7f8f9d']
      },
      BscMainnet: {
        url:"https://bnb-mainnet.g.alchemy.com/v2/3BH10F7T5x3xp5eOUF9vhTnu7MIv7yz_",
        accounts: ['a6a6cbe826ae0753ea6652869340b06224430e7558bae1637d384418cd7f8f9d']
      },
    },
    solidity: {
      compilers: [
        {
          version: "0.8.29",
          settings: {
            optimizer: {
                      enabled: true,
                      runs: 200
          }
          }
        },
        {
          version: "0.8.9",
          settings: {
            optimizer: {
                      enabled: true,
                      runs: 200
          }
          }
        }
      ],
    },
  };
  
export default config;
