const piggyGame = artifacts.require("piggyGame")
const profileNFT = artifacts.require("WBProfileNFT")
const boosterNFT = artifacts.require("boosterNFT")
const PiggyBankToken = artifacts.require("PiggyBankToken")

module.exports = function(deployer) {
    return deployer.deploy(profileNFT).then(() => {
      return deployer.deploy(boosterNFT).then(() => {
        return deployer.deploy(piggyGame, "0xcd2ecd5e06b1a330789b30e8ada3d11c51503a71", boosterNFT.address)
    })
  })
}
