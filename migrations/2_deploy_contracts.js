const piggyGame = artifacts.require("piggyGame")
const profileNFT = artifacts.require("WBProfileNFT")
// const boosterNFT = artifacts.require("boosterNFT")
const boosterNFT = artifacts.require("piggyNFT")

module.exports = function(deployer) {
    return deployer.deploy(profileNFT).then(() => {
      return deployer.deploy(boosterNFT).then(() => {
        return deployer.deploy(piggyGame, "0xcd2ecd5e06b1a330789b30e8ada3d11c51503a71", boosterNFT.address, "0x10ed43c718714eb63d5aa57b78b54704e256024e")
    })
  })
}
