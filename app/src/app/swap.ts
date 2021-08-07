
import { Fetcher, WETH, Route, Trade, TradeType, TokenAmount, Percent } from '@pancakeswap/sdk'
import { ethers, utils } from "ethers";
import { Web3Provider, JsonRpcProvider } from '@ethersproject/providers';
import { Contract } from '@ethersproject/contracts';
import { BigNumber } from '@ethersproject/bignumber';
import { ChainId, Token } from '@pancakeswap/sdk'

import { PIGGY } from './piggy';

export const PANCAKE_ROUTER_V2 = '0x10ed43c718714eb63d5aa57b78b54704e256024e'

export async function buyTokensAPI(amount: number, recipient: string){
    const wprovider = new JsonRpcProvider("http://localhost:8545")
    const pair = await Fetcher.fetchPairData(PIGGY, WETH[PIGGY.chainId], wprovider)
    const route = new Route([pair], WETH[PIGGY.chainId])
    const trade = new Trade(route, new TokenAmount(WETH[PIGGY.chainId], utils.parseEther(amount.toString()).toString()), TradeType.EXACT_INPUT)
    const slippageTolerance = new Percent('100', '10000') // 1600 bips, or 16%

    // Transaction parameters
    const amountOutMin = trade.minimumAmountOut(slippageTolerance).raw
    const path = [WETH[PIGGY.chainId].address, PIGGY.address]
    const value = trade.inputAmount.raw
    const deadline = Math.floor(Date.now() / 1000) + 60 * 20
    const to = recipient
    const signer = wprovider.getSigner()

    // Load PCS RouterV2 contract
    const pancakeswap = new Contract(
        PANCAKE_ROUTER_V2,
        [
            'function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts)',
            'function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts)'
        ],
        signer
    )
    const tx = await pancakeswap.swapETHForExactTokens(
        amountOutMin.toString(),
        path,
        to,
        deadline,
        { gasLimit: ethers.utils.hexlify(300000), value: BigNumber.from(value.toString()), }
    )
    console.log(tx)
    console.log(await tx.wait())
}

export async function tokenQuote(amount: number, tokenAddress: string, tokenDecimals: string, tokenSymbol: string): Promise<[string, string]> {
    const TOKEN = new Token(ChainId.MAINNET, tokenAddress, parseInt(tokenDecimals), tokenSymbol)

    const wprovider = new JsonRpcProvider("http://localhost:8545")
    const pair = await Fetcher.fetchPairData(TOKEN, WETH[TOKEN.chainId], wprovider)
    const route = new Route([pair], WETH[TOKEN.chainId])
    const trade = new Trade(route, new TokenAmount(WETH[TOKEN.chainId], utils.parseEther(amount.toString()).toString()), TradeType.EXACT_INPUT)
    const slippageTolerance = new Percent('100', '10000')

    // Transaction parameters
    const amountOutMin = trade.minimumAmountOut(slippageTolerance).raw
    const value = trade.inputAmount.raw
    return [value.toString(), amountOutMin.toString()]
}