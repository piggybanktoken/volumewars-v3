const piggyGame = artifacts.require("piggyGame")
const rewardNFT = artifacts.require("piggyNFT")

module.exports = function(deployer) {
  return deployer.deploy(piggyGame, "0xcd2ecd5e06b1a330789b30e8ada3d11c51503a71", "0x10ed43c718714eb63d5aa57b78b54704e256024e").then(() => {
    return deployer.deploy(rewardNFT, piggyGame.address)
  })
}