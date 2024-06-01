import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("@nomiclabs/hardhat-waffle");
require("dotenv").config({ path: ".env" });

const privateKey: string = process.env.CELO_PRIVATEKEY!;

const config: HardhatUserConfig = {
  solidity: "0.8.26",
  defaultNetwork: "alfajores",
  networks: {
    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts: [privateKey],
      chainId: 44787,
    },
    celo: {
      url: "https://forno.celo.org",
      accounts: [privateKey],
      chainId: 42220,
    },
  },
};

export default config;
