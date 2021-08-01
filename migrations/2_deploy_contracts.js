const piggyGame = artifacts.require("piggyGame")
const rewardNFT = artifacts.require("piggyNFT")
const MAINNET_PIGGY = "0xcd2ecd5e06b1a330789b30e8ada3d11c51503a71"
const MAINNET_PCS = "0x10ed43c718714eb63d5aa57b78b54704e256024e"
const TESTNET_PIGGY = "0xd610e8523b335e6f3cebf1bd564800b755eafdfe"
const TESTNET_PCS = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3"
module.exports = async (deployer, network, [defaultAccount]) => {
  console.log(network)
  if (!network.startsWith('testnet')) {
    return deployer.deploy(piggyGame, MAINNET_PIGGY, MAINNET_PCS).then(() => {
      return deployer.deploy(rewardNFT, piggyGame.address)
    })
  }
  return deployer.deploy(piggyGame, TESTNET_PIGGY, TESTNET_PCS).then(() => {
    return deployer.deploy(rewardNFT, piggyGame.address)
  })
  
}