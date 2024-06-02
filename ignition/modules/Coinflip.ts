import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CoinflipModule = buildModule("CoinflipModule", (m) => {
  const coinflip = m.contract("Coinflip");
  return { coinflip };
});

export default CoinflipModule;
