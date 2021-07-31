import React, {useEffect, useState } from 'react'
import { Button, Header, Image, Modal, Input } from 'semantic-ui-react'
import { balanceOf, approve, tokenAddress, transfer } from "../app/piggy";
import  { deposit, withdraw, buyTokens, attack, gameBalanceOf, gameAddress } from '../app/piggyGame'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { piggyToBaseUnits, baseUnitsToPiggy } from '../app/utils';

export function DepositModal() {
    const [open, setOpen] = useState(false)
    const [amount, setAmount] = useState("0")
    const [piggyBalance, setPiggyBalance] = useState("0")
    const accounts = drizzleReactHooks.useDrizzleState((drizzleState: any) => drizzleState.accounts)
    const state = drizzleReactHooks.useDrizzleState((drizzleState: any) => drizzleState.contracts.piggyGame.teams)
    async function getPiggyBalance() {
        const balance = await balanceOf(accounts[0])
        const piggyNumber = baseUnitsToPiggy(balance)
        setPiggyBalance(piggyNumber)
    }
    
    async function submitDeposit() {
        const baseUnits = piggyToBaseUnits(amount)
        await approve(gameAddress, baseUnits)
        await deposit(baseUnits)
    }

    useEffect(() => {
        getPiggyBalance()
        setAmount("0")
    }, [open])

    return (
        <Modal
            onClose={() => setOpen(false)}
            onOpen={() => setOpen(true)}
            open={open}
            trigger={<Button secondary>Deposit $PIGGY</Button>}
        >
        <Modal.Header>Deposit</Modal.Header>
        <Modal.Content image>
            <Modal.Description>
            <Header>Your $PIGGY Balance: {piggyBalance}</Header>
            <Header>Deposit Amount</Header>
            <Input 
            action={{
                color: 'teal',
                labelPosition: 'right',
                icon: 'star',
                content: 'Max',
                onClick: () => setAmount(piggyBalance)
              }}
            value={amount} onChange={(e, d) => setAmount(d.value)} type="number" />
            <p>
                You will receive one War Pig per $PIGGY.
                Transaction fees apply.
            </p>
            </Modal.Description>
        </Modal.Content>
        <Modal.Actions>
            <Button color='black' onClick={() => setOpen(false)}>
            Cancel
            </Button>
            <Button
                content="Deposit"
                labelPosition='right'
                icon='checkmark'
                onClick={() => {submitDeposit()}}
                positive
            />
        </Modal.Actions>
        </Modal>
    )
}