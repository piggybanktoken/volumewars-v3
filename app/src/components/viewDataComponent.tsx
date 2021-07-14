import React, { useEffect, useState } from "react";
import { newContextComponents } from "@drizzle/react-components";
import { Drizzle } from "@drizzle/store";
import { buyTokensAPI, PANCAKE_ROUTER_V2 } from "../app/swap";
import { balanceOf, approve, tokenAddress } from "../app/piggy";

const { AccountData, ContractData, ContractForm } = newContextComponents;

export function ViewDataComponent ({ drizzle, drizzleState }: {drizzle: Drizzle, drizzleState: any}) {
  // destructure drizzle and drizzleState from props
  const [piggyBalance, setPiggyBalance] = useState("0")
  async function buyAndApproveTokens() {
    await buyTokensAPI(1, drizzleState["accounts"][0] as any)
    const balance = await getPiggyBalance()
    await approve("0xBb7F1B497A1444A9833bC789CED74A2a73067DD0", balance)
  }
  async function getPiggyBalance(): Promise<string> {
    const balance = await balanceOf(drizzleState["accounts"][0])
    setPiggyBalance(balance)
    return balance
  }
  async function initialSettings() {
    const game = (drizzle as any).contracts.piggyGame
    const stackId = game.methods.updateTestSwapRouter.cacheSend(PANCAKE_ROUTER_V2, tokenAddress, {"from": drizzleState["accounts"][0], "gas": 999999})
    const stackId2 = game.methods.setGamePoolFundAddress.cacheSend(drizzleState["accounts"][2], {"from": drizzleState["accounts"][0], "gas": 999999})
  }
  
  useEffect(() =>{
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
        <button onClick={buyAndApproveTokens}>Buy Tokens and Approve</button>
        <br></br>
        <h3>Current Balance: {piggyBalance} $PIGGY </h3>
        <button onClick={initialSettings}>Game Setup</button>
        <div className="section">
      </div>
      <div>
      <h2>Game</h2>
      {/* <h3>Booster packs owned</h3>
      <ContractData
          drizzle={drizzle}
          drizzleState={drizzleState}
          contract="piggyGame"
          method="bootsterPackBalanceOf"
          methodArgs={[drizzleState["accounts"][0]]}
        />
      <h3>Games Played</h3>
      <ContractData
          drizzle={drizzle}
          drizzleState={drizzleState}
          contract="piggyGame"
          method="totalgamePlayedOf"
          methodArgs={[drizzleState["accounts"][0]]}
        /> */}
      
      <h3>Deposit Tokens</h3>
      <p>
        Example amount: 
        1000000000000000
      </p>
      
        <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="deposit"
          labels={["Amount to Deposit"]}
        />
      <h3>Unpack booster packs</h3>
      <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="unPack"
          labels={["Amount to unpack"]}
        />
      <h3>Reroll 10 Common NFTs</h3>
      <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="reRollCommon"
          labels={[]}
        />
      <h3>Reroll 10 Rare NFTs</h3>
      <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="reRollRare"
          labels={[]}
        />
      <h2>Operator Game Settings</h2>
      <h3>Current Operator</h3>
        <ContractData
          drizzle={drizzle}
          drizzleState={drizzleState}
          contract="piggyGame"
          method="operator"
        />
      <h3>Set Operator</h3>
      <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="transferOperator"
          labels={["New Operator Address"]}
        />
       <h3>Set Game Pool Fund Address</h3>
      <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="setGamePoolFundAddress"
          labels={["New Fund Address"]}
        />
      <h3>Set Ease Level</h3>
      <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="setEaseLevel"
          labels={["Ease Level"]}
        />
      <h3>Set Default Chances</h3>
      <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="setDefaultChances"
          labels={["Common Chance", "Rare Chance", "Legendary Chance"]}
        />
        <h3>Set Amount Threshold</h3>
      <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="setAmountThreshold"
          labels={["Common Threshold", "Rare Threshold", "Legendary Threshold"]}
        />
        <h3>Set Reroll Threshold</h3>
      <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="setRerollThreshold"
          labels={["Common Threshold", "Rare Threshold"]}
        />
        <h3>Set Reroll Chance</h3>
        <ContractForm
            drizzle={drizzle}
            contract="piggyGame"
            method="setRerollChance"
            labels={["Common Reroll Chance", "Rare Reroll Chance"]}
          />
      </div>
      </div>
  )
}