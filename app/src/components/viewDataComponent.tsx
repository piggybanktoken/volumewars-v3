import React, { useEffect, useState, useContext } from "react";
import { newContextComponents } from "@drizzle/react-components";
import { Drizzle } from "@drizzle/store";
import { buyTokensAPI, PANCAKE_ROUTER_V2 } from "../app/swap";
import { balanceOf, approve, tokenAddress, transfer } from "../app/piggy";
import  { deposit, withdraw, buyTokens, attack, gameBalanceOf } from '../app/piggyGame'
import { gameAddress, nftAddress } from "../app/piggyGame";
import { Button, Checkbox, Form } from 'semantic-ui-react'
import { drizzleReactHooks } from '@drizzle/react-plugin'

const { AccountData, ContractData, ContractForm } = newContextComponents;

export function ViewDataComponent() {
  const drizzleState = drizzleReactHooks.useDrizzleState((drizzleState: {accounts: any}) => drizzleState)
  const {
    drizzle,
    useCacheCall,
    useCacheEvents,
    useCacheSend
  } = drizzleReactHooks.useDrizzle()

  // destructure drizzle and drizzleState from props
  const [piggyBalance, setPiggyBalance] = useState("0")
  async function buyAndApproveTokens() {
    await buyTokensAPI(1, drizzleState["accounts"][0] as any)
    const balance = await getPiggyBalance()
    await approve(gameAddress, balance)
  }
  async function getPiggyBalance(): Promise<string> {
    const balance = await balanceOf(drizzleState["accounts"][0])
    setPiggyBalance(balance)
    return balance
  }
  const game = (drizzle as any).contracts.piggyGame
  async function initialSettings() {
    // game.methods.updatePancakeSwapRouter.cacheSend(PANCAKE_ROUTER_V2, tokenAddress, {"from": drizzleState["accounts"][0], "gas": 999999})
    game.methods.updateNFTAddress.cacheSend(nftAddress)
    game.methods.openSeason.cacheSend()
    game.methods.buyTokens.cacheSend("150000000000000000000", { from: drizzleState["accounts"][0], value: "50000000000000000000"})
  }
  useEffect(() =>{
    console.log(drizzleState)
    getPiggyBalance()
  },[])
  return (
      <div>
        <h2>Active Account</h2>
        <AccountData
        drizzle={drizzle}
        drizzleState={drizzleState}
        accountIndex={0}
        units="ether"
        precision={3}
        />
        <Button onClick={buyAndApproveTokens}>Buy Tokens and Approve</Button>
        <br></br>
        <h3>Current Balance: {piggyBalance} $PIGGY </h3>
        <h3>Current Game Balance</h3>
        <h4>
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="piggyGame"
            method="balanceOf"
            methodArgs={[drizzleState["accounts"][0]]}
          />
        </h4>
        <hr></hr>
        <Button onClick={initialSettings}>Game Setup</Button>
        <Button onClick={() => {transfer(gameAddress, "50000000000000000").then(() => getPiggyBalance())}}>Send Piggy</Button>
        <Button onClick={() => {deposit("50000000000000000").then(() => getPiggyBalance())}} >Deposit</Button>
        <Button onClick={() => {balanceOf(gameAddress).then((res) => console.log(res))}} >Get Game Balance</Button>
        <Button onClick={() => {gameBalanceOf(drizzleState["accounts"][0]).then((res) => console.log(res))}} >Get User Game Balance</Button>
        <Button onClick={() => {gameBalanceOf(drizzleState["accounts"][0]).then((res) => withdraw(res))}} >Withdraw All</Button>
        <Button onClick={() => {game.methods.buyTokens.cacheSend("1500000000000000000000", { from: drizzleState["accounts"][0], value: "50000000000000000000"})}}>Buy Tokens</Button>
        <Button onClick={() => {attack("25000000000000000").then((res) => console.log(res))}} >Attack</Button>
        <div className="section">
      </div>
      <div>
      <h2>Game</h2>
      
      <h3>Deposit Tokens</h3>
      <p>
        Example amount: 
        1000000000000000
      </p>
        <Form.Field as={ContractForm}
          drizzle={drizzle}
          contract="piggyGame"
          method="deposit"
          labels={["Amount to Deposit"]}
        />
      <h2>Operator Game Settings</h2>
      <h3>Current Operator</h3>
      </div>
      </div>
  )
}
