const piggyGame = artifacts.require("piggyGame")
const rewardNFT = artifacts.require("piggyNFT")

contract("PiggyGame", accounts => {
  it("Should buy tokens", async () => {
    const game = await piggyGame.deployed()
    const nft = await rewardNFT.deployed()
    const balance = await game.balanceOf.call(accounts[0])
    assert.equal(balance, 0, "Balance not zero")
    await game.updateNFTAddress(nft.address)
    await game.setOpen(true)
    await game.updatePancakeSwapRouter("0x10ed43c718714eb63d5aa57b78b54704e256024e", '0xcd2ecd5e06b1a330789b30e8ada3d11c51503a71')
    await game.addTeam()
    await game.addTeam()
    await game.setSeason(1)
    await game.join({ from: accounts[0] , value: "100000000000000000"})
    await game.mintNFT(accounts[0], 5, 6);
    await game.transferOwnership(accounts[1])
    const nfts = await nft.tokenOfOwnerByIndex.call(accounts[0], 0)
    const nftbalance = await nft.balanceOf.call(accounts[0])
    const owner = await nft.ownerOf.call(nfts)
    const {0: series, 1: number} = await nft.metadataOf.call(nfts)
    console.log(nfts.toString(), nftbalance.toString(), owner.toString(), series.toString(), number.toString())

    await game.buyTokens("50000000000000000", { from: accounts[0] , value: "50000000000000000"})
    const balanceAfter = await game.balanceOf.call(accounts[0])
    assert.equal(balanceAfter.toString(), "42500000212500001", "Balance not correct")
    await game.withdraw("42500000212500001")
    const balanceFinal = await game.balanceOf.call(accounts[0])
    assert.equal(balanceFinal, 0, "Balance not zero")
    await game.buyTokens("5000000000000000000", { from: accounts[0] , value: "500000000000000000"})
    await game.attack("50000000000000000", 2)
  })
})
