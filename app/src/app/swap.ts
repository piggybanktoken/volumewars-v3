
import { ChainId, Fetcher, Token, WETH, Route, Trade, TradeType, TokenAmount, Percent } from '@pancakeswap/sdk'
import { ethers, utils } from "ethers";
import { Web3Provider, JsonRpcProvider } from '@ethersproject/providers';
import { Contract } from '@ethersproject/contracts';
import { BigNumber } from '@ethersproject/bignumber';

export const tokenAddress = '0xcd2ecd5e06b1a330789b30e8ada3d11c51503a71'
const decimals = 9
const chainId = ChainId.MAINNET
const PIGGY = new Token(chainId, tokenAddress, decimals, "PIGGY")

export const PANCAKE_ROUTER_V2 = '0x10ed43c718714eb63d5aa57b78b54704e256024e'

export async function buyTokensAPI(amount: number, recipient: string){
    const wprovider = new JsonRpcProvider("http://localhost:8545")
    const pair = await Fetcher.fetchPairData(PIGGY, WETH[chainId], wprovider)
    const route = new Route([pair], WETH[chainId])
    const trade = new Trade(route, new TokenAmount(WETH[chainId], utils.parseEther(amount.toString()).toString()), TradeType.EXACT_INPUT)
    const slippageTolerance = new Percent('100', '10000') // 1600 bips, or 16%

    // Transaction parameters
    const amountOutMin = trade.minimumAmountOut(slippageTolerance).raw
    const path = [WETH[chainId].address, PIGGY.address]
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