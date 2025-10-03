import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
    etherscan: {
      apiKey: {
        BscMainnet: "Q6VCHDYPPATQHPS4CR3AUUQ41ARAMSXZA4",
      },
    customChains: [
    {
      network: "BscMainnet",
      chainId: 56,
      urls: {
        apiURL: "https://api.etherscan.io/v2/api?chainid=56",
        browserURL: "https://bscscan.com/"
      }
    },]
    },
    networks: {
      BscTestnet: {
        url: "https://data-seed-prebsc-2-s1.binance.org:8545/",
        accounts: ['']
      },
      BscMainnet: {
        url:"https://bnb-mainnet.g.alchemy.com/v2/3BH10F7T5x3xp5eOUF9vhTnu7MIv7yz_",
        accounts: ['']
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
