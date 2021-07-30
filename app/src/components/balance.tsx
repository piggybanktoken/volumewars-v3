import React, { useState, useEffect } from "react";
import { Header, Button } from 'semantic-ui-react';
import { Drizzle } from "@drizzle/store";

/*
 * TODO:
 * - Hook up to smart contract
 */

function BalanceDisplay({ drizzle, drizzleState }: {drizzle: Drizzle, drizzleState: any}) {
    const [balanceKey, setBalanceKey] = useState('')
    const balanceLocation = (drizzle as any).store.getState().contracts.piggyGame.balanceOf

    useEffect(
        () => {
            const contract = (drizzle as any).contracts.piggyGame
            const key = contract.methods.balanceOf.cacheCall(drizzleState.accounts[0])
            setBalanceKey(key)
        }, [balanceKey, (drizzle as any).contracts.piggyGame]
    )

    function getBalance() {
        if (balanceKey && balanceLocation && balanceLocation[balanceKey])
            return balanceLocation[balanceKey].value
        return 0
    }


    return (
        <div>
            <Header size="medium" className="header-margin-1">{getBalance()} PIGGY</Header>
        </div>
    )
}

function DepositButton() {
    return (
        <Button.Group vertical>
            <Button color="pink">Deposit PIGGY</Button>
            <Button color="orange">Buy PIGGY</Button>
        </Button.Group>
    )
}

export { BalanceDisplay, DepositButton }
