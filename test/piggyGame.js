const piggyGame = artifacts.require("piggyGame")
const rewardNFT = artifacts.require("piggyNFT")

contract("PiggyGame", accounts => {
  it("Should forge Legendaries", async () => {
    const game = await piggyGame.deployed()
    const nft = await rewardNFT.deployed()
    await game.updateNFTAddress(nft.address)
    await nft.addSet(1, 7)
    for (i = 1; i != 8; i++) {
      await game.mintNFT(accounts[0], 1, i);
    }
    const ownNFTs = [];
    for (i = 0; i != 7; i++) {
      const c = await nft.tokenOfOwnerByIndex.call(accounts[0], i)
      const {0: series, 1: number} = await nft.metadataOf.call(c)
      assert.equal(series, 1, "Wrong Series for Card")
      assert.equal(number, i+1, "Wrong Card Number")
      ownNFTs.push(c);
    }
    const tx = await game.forgeLegendary(ownNFTs);
    console.log(accounts[0])
    const legendary = await nft.tokenOfOwnerByIndex.call(accounts[0], 0) // First NFT because all others were burned
    const {0: series, 1: number} = await nft.metadataOf.call(legendary)
    assert.equal(series, 1, "Wrong Series for Legendary")
    assert.equal(number, 0, "Invalid Legendary")
  })
  it("Should buy tokens", async () => {
    const game = await piggyGame.deployed()
    const nft = await rewardNFT.deployed()
    const balance = await game.balanceOf.call(accounts[0])
    assert.equal(balance, 0, "Balance not zero")
    await game.updateNFTAddress(nft.address)
    await game.addTeam()
    await game.addTeam()
    await game.openSeason();
    await game.join({ from: accounts[0] , value: "10000000000000000"})
    await game.buyTokens("400000000000000000", { from: accounts[0] , value: "10000000000000000"})
    const balanceAfter = await game.balanceOf.call(accounts[0])
    assert.equal(balanceAfter, "340000013600000544", "Balance not correct")
    await game.withdraw("340000013600000544")
    const balanceFinal = await game.balanceOf.call(accounts[0])
    assert.equal(balanceFinal, 0, "Balance not zero")
    await game.buyTokens("400000000000000000", { from: accounts[0] , value: "10000000000000000"})
    const res = await game.attack("340000013600000544", 2)
  })
})
