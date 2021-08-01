import Web3 from "web3"
import piggyGame from "./contracts/piggyGame.json"
import piggyNFT from "./contracts/piggyNFT.json"

const options = {
  // web3: {
  //   block: false,
  //   customProvider: new Web3((window as any).ethereum),
  // },
  contracts: [piggyGame, piggyNFT],
  // events: {
  //   SimpleStorage: ["StorageSet"],
  // },
}

export default options
