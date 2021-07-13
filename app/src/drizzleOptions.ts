import Web3 from "web3"
import piggyGameWithNFT from "./contracts/piggyGame.json"
import profileNFT from "./contracts/WBProfileNFT.json"
import rewardNFT from "./contracts/boosterNFT.json"

const options = {
  web3: {
    block: false,
    customProvider: new Web3("ws://localhost:8545"),
  },
  contracts: [piggyGameWithNFT, profileNFT, rewardNFT],
  // events: {
  //   SimpleStorage: ["StorageSet"],
  // },
}

export default options
