import { ChainId, Fetcher, Token, WETH, Route, Trade, TradeType, TokenAmount, Percent } from '@pancakeswap/sdk'
import { ethers, utils } from "ethers"
import { Web3Provider, JsonRpcProvider } from '@ethersproject/providers'
import { Contract } from '@ethersproject/contracts'
import { BigNumber } from '@ethersproject/bignumber'

import * as abi from '../contracts/piggyGame.json'
import * as nftABI from '../contracts/piggyNFT.json'
export const gameAddress = abi.networks[56].address
export const nftAddress = nftABI.networks[56].address

function getContract(): ethers.Contract {
    const wprovider = new JsonRpcProvider("http://localhost:8545")
    const signer = wprovider.getSigner()
    return new Contract(
        gameAddress,
        [
            'function deposit(uint256 amount) public',
            'function withdraw(uint256 amount) public',
            'function buyTokens(uint256 minTokens) public payable',
            'function attack(uint256 amount, uint32 team) public',
            'function balanceOf(address player) public view returns (uint256)',
            'function join() public payable'
        ],
        signer
    )
}

export async function deposit(amount: string) {
    const game = getContract()
    const tx = await game.deposit(amount)
    console.log(tx)
    console.log(await tx.wait())
}

export async function withdraw(amount: string) {
    const game = getContract()
    const tx = await game.withdraw(amount)
    console.log(tx)
    console.log(await tx.wait())
}

export async function buyTokens(ETHAmount: string, minTokens: string) {
    const game = getContract()
    const tx = await game.buyTokens(minTokens,
        { gasLimit: ethers.utils.hexlify(300000), value: utils.parseEther(ETHAmount) }
    )
    console.log(tx)
    console.log(await tx.wait())
}

export async function attack(amount: string, team: string) {
    const game = getContract()
    const tx = await game.attack(amount, team)
    console.log(tx)
    console.log(await tx.wait())
}

export async function gameBalanceOf(account: string): Promise<string> {
    const game = getContract()
    return (await game.balanceOf(account)).toString()
}

export async function join() {
    const game = getContract()
    const tx = await game.join(
        { gasLimit: ethers.utils.hexlify(300000), value: utils.parseEther("0.1") }
    )
    console.log(tx)
    console.log(await tx.wait())
}