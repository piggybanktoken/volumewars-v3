const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const piggyGame = artifacts.require("piggyGame")
const rewardNFT = artifacts.require("piggyNFT")
const MAINNET_PIGGY = "0xcd2ecd5e06b1a330789b30e8ada3d11c51503a71"
const MAINNET_PCS = "0x10ed43c718714eb63d5aa57b78b54704e256024e"
const TESTNET_PIGGY = "0xd610e8523b335e6f3cebf1bd564800b755eafdfe"
const TESTNET_PCS = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3"

const MAINNET_SAFEMOON = "0x8076c74c5e3f5852037f31ff0093eeb8c8add8d3"
const TESTNET_SAFEMOON = "0xDAcbdeCc2992a63390d108e8507B98c7E2B5584a"


const MAINNET_LINK = {
  coordinator: "0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31",
  hash: "0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c",
  token: "0x404460C6A5EdE2D891e8297795264fDe62ADBB75",
  fee: "200000000000000000"
}
const TESTNET_LINK = {
  token: "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06",
  coordinator: "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C",
  hash: "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186",
  fee: "100000000000000000"
}
module.exports = async (deployer, network, [defaultAccount]) => {
  if (network.startsWith('develop')) {
    const instance = await deployProxy(piggyGame, [MAINNET_PIGGY, MAINNET_SAFEMOON, MAINNET_PCS, MAINNET_LINK.coordinator, MAINNET_LINK.token, MAINNET_LINK.hash, MAINNET_LINK.fee], { deployer });
    return deployer.deploy(rewardNFT, instance.address)
  }
  if (network.startsWith('testnet')) {
    const instance = await deployProxy(piggyGame, [TESTNET_PIGGY, TESTNET_SAFEMOON, TESTNET_PCS, TESTNET_LINK.coordinator, TESTNET_LINK.token, TESTNET_LINK.hash, TESTNET_LINK.fee], { deployer });
    return deployer.deploy(rewardNFT, instance.address)
  }
}