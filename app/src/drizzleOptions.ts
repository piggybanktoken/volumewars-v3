import Web3 from "web3"
import piggyGame from "./contracts/piggyGame.json"
import WBProfileNFT from "./contracts/WBProfileNFT.json"
import boosterNFT from "./contracts/boosterNFT.json"

const options = {
  web3: {
    block: false,
    customProvider: new Web3("ws://localhost:8545"),
  },
  contracts: [piggyGame],
  // events: {
  //   SimpleStorage: ["StorageSet"],
  // },
}

export default options
