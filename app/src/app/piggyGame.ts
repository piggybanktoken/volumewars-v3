import { ChainId, Fetcher, Token, WETH, Route, Trade, TradeType, TokenAmount, Percent } from '@pancakeswap/sdk'
import { ethers, utils } from "ethers"
import { Web3Provider, JsonRpcProvider } from '@ethersproject/providers'
import { Contract } from '@ethersproject/contracts'
import { BigNumber } from '@ethersproject/bignumber'


export const gameAddress = '0x458c0D2b159521AB35ab327a7D53675003892a67'

function getContract(): ethers.Contract {
    const wprovider = new JsonRpcProvider("http://localhost:8545")
    const signer = wprovider.getSigner()
    return new Contract(
        gameAddress,
        [
            'function deposit(uint256 amount) public',
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