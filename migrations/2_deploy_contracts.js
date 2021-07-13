// const SimpleStorage = artifacts.require("SimpleStorage")
// const TutorialToken = artifacts.require("TutorialToken")
// const ComplexStorage = artifacts.require("ComplexStorage")

const piggyGame = artifacts.require("piggyGame")
const profileNFT = artifacts.require("WBProfileNFT")
const boosterNFT = artifacts.require("boosterNFT")
const PiggyBankToken = artifacts.require("PiggyBankToken")

module.exports = function(deployer) {
  // deployer.deploy(SimpleStorage)
  // deployer.deploy(TutorialToken)
  // deployer.deploy(ComplexStorage)
  deployer.deploy(PiggyBankToken).then(() => {
    deployer.deploy(profileNFT)
    deployer.deploy(boosterNFT).then(() => {
      deployer.deploy(piggyGame, PiggyBankToken.address, boosterNFT.address)
    })
  })
}
