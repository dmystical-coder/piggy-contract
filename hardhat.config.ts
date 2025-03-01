import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

require("dotenv").config();

const {
  ACCOUNT_PRIVATE_KEY,
  ALCHEMY_BASE_SEPOLIA_API_KEY_URL,
  BASESCAN_API_KEY
} = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    hardhat: {},
    "base-sepolia": {
      url: ALCHEMY_BASE_SEPOLIA_API_KEY_URL,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: {
      baseSepolia: BASESCAN_API_KEY || "",
    },
  }
};

export default config;
