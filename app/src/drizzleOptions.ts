import Web3 from "web3"
import piggyGame from "./contracts/piggyGame.json"
import WBProfileNFT from "./contracts/WBProfileNFT.json"
import boosterNFT from "./contracts/boosterNFT.json"
import PiggyBankToken from "./contracts/PiggyBankToken.json"

const options = {
  web3: {
    block: false,
    customProvider: new Web3("ws://localhost:8545"),
  },
  contracts: [PiggyBankToken],
  // events: {
  //   SimpleStorage: ["StorageSet"],
  // }, piggyGame, WBProfileNFT, boosterNFT, 
}

export default options
