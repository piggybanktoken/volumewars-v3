import { ChainId, Token } from '@pancakeswap/sdk'
import { ethers } from "ethers"
import { Web3Provider } from '@ethersproject/providers'
import { Contract } from '@ethersproject/contracts'

export const tokenAddress = '0xcd2ecd5e06b1a330789b30e8ada3d11c51503a71'
const TESTNET_PIGGY = "0xd610e8523b335e6f3cebf1bd564800b755eafdfe"

const decimals = 9
export const PIGGY = new Token(ChainId.TESTNET, TESTNET_PIGGY, decimals, "PIGGY")

function getContract(address: string): ethers.Contract {
    const wprovider = new Web3Provider((window as any).ethereum as any,  {name: "binance", chainId: 97 })
    const signer = wprovider.getSigner()
    return new Contract(
        address,
        [
            'function balanceOf(address account) external view returns (uint256)',
            'function transfer(address recipient, uint256 amount) external returns (bool)',
            'function allowance(address owner, address spender) external view returns (uint256)',
            'function approve(address spender, uint256 amount) external returns (bool)',
            'function transferFrom(address sender, address recipient, uint256 amount) external returns (bool)'
        ],
        signer
    )
}

export async function balanceOf(account: string, tokenAddress: string): Promise<string> {
    const piggy = getContract(tokenAddress)
    return (await piggy.balanceOf(account)).toString()
}

export async function approve(spender: string,  amount: string, tokenAddress: string): Promise<boolean> {
    const piggy = getContract(tokenAddress)
    return await piggy.approve(spender, amount)
}
export async function transfer(recipient: string, amount: string, tokenAddress: string): Promise<boolean> {
    const piggy = getContract(tokenAddress)
    return await piggy.transfer(recipient, amount)
}