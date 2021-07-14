const piggyGame = artifacts.require("piggyGame")
const profileNFT = artifacts.require("WBProfileNFT")
const boosterNFT = artifacts.require("boosterNFT")
const PiggyBankToken = artifacts.require("PiggyBankToken")

module.exports = function(deployer) {
  deployer.deploy(PiggyBankToken).then(() => {
    deployer.deploy(profileNFT)
    deployer.deploy(boosterNFT).then(() => {
      deployer.deploy(piggyGame, PiggyBankToken.address, boosterNFT.address)
    })
  })
}
