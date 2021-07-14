import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import { Drizzle } from "@drizzle/store";

const { AccountData, ContractData, ContractForm } = newContextComponents;

export function ViewDataComponent ({ drizzle, drizzleState }: {drizzle: Drizzle, drizzleState: any}) {
  // destructure drizzle and drizzleState from props
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
        <div className="section">
        <h2>Token</h2>
        <p>
          <strong>Total Supply: </strong>
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="PiggyBankToken"
            method="totalSupply"
            methodArgs={[{ from: drizzleState.accounts[0] }]}
          />{" "}
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="PiggyBankToken"
            method="symbol"
            hideIndicator
          />
        </p>
        <p>
          <strong>My Balance: </strong>
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="PiggyBankToken"
            method="balanceOf"
            methodArgs={[drizzleState.accounts[0]]}
          />
        </p>
        <h3>Send Tokens</h3>
        <ContractForm
          drizzle={drizzle}
          contract="PiggyBankToken"
          method="transfer"
          labels={["To Address", "Amount to Send"]}
        />
        <h3>Approve Tokens</h3>
        <ContractForm
          drizzle={drizzle}
          contract="PiggyBankToken"
          method="approve"
          labels={["To Address", "Amount to Approve"]}
        />
      </div>
      <div>
      <h2>Game</h2>
      <h3>Owner</h3>
        <ContractData
          drizzle={drizzle}
          drizzleState={drizzleState}
          contract="piggyGame"
          method="operator"
        />
      <h3>Set Game Pool Address</h3>
        Example Address: 
        <AccountData
        drizzle={drizzle}
        drizzleState={drizzleState}
        accountIndex={0}
        units="ether"
        precision={3}
        />
      <ContractForm
          drizzle={drizzle}
          contract="piggyGame"
          method="setGamePoolFundAddress"
          labels={["Game Pool Address"]}
        />
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
      </div>
      </div>
  )
}