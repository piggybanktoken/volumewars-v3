import React, {useEffect, useState } from 'react'
import { Button, Header, Image, Modal, Input } from 'semantic-ui-react'
import  { withdraw } from '../app/piggyGame'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { piggyToBaseUnits, baseUnitsToPiggy } from '../app/utils';

export function WithdrawModal() {
    const [open, setOpen] = useState(false)
    const [amount, setAmount] = useState("0")
    const accounts = drizzleReactHooks.useDrizzleState((drizzleState: any) => drizzleState.accounts)
    const {
        useCacheCall,
    } = drizzleReactHooks.useDrizzle()
    const balance = useCacheCall('piggyGame', 'balanceOf', accounts[0])
    
    async function submitWithdraw() {
        const baseUnits = piggyToBaseUnits(amount)
        console.log(baseUnits)
        await withdraw(baseUnits)
        setOpen(false)
    }

    useEffect(() => {
        setAmount("0")
    }, [open])

    return (
        <Modal
            onClose={() => setOpen(false)}
            onOpen={() => setOpen(true)}
            open={open}
            trigger={<Button secondary>Withdraw War Pigs</Button>}
        >
        <Modal.Header>Withdraw War Pigs</Modal.Header>
        <Modal.Content image>
            <Modal.Description>
            <Header>Your War Pigs Balance: {baseUnitsToPiggy(balance)}</Header>
            <Header>Withdraw Amount</Header>
            <Input 
            action={{
                color: 'teal',
                labelPosition: 'right',
                icon: 'star',
                content: 'All',
                onClick: () => setAmount(baseUnitsToPiggy(balance))
              }}
            value={amount} onChange={(e, d) => setAmount(d.value)} type="number" />
            <p>
                You will receive one $PIGGY per War Pig.
                Transaction fees apply.
            </p>
            </Modal.Description>
        </Modal.Content>
        <Modal.Actions>
            <Button color='black' onClick={() => setOpen(false)}>
            Cancel
            </Button>
            <Button
                content="Withdraw"
                labelPosition='right'
                icon='checkmark'
                onClick={() => {submitWithdraw()}}
                positive
            />
        </Modal.Actions>
        </Modal>
    )
}