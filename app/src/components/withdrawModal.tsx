import React, {useEffect, useState } from 'react'
import { Button, Header, Image, Modal, Input } from 'semantic-ui-react'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { piggyToBaseUnits, baseUnitsToPiggy } from '../app/utils';

export function WithdrawModal() {
    const [open, setOpen] = useState(false)
    const [amount, setAmount] = useState("0")
    const accounts = drizzleReactHooks.useDrizzleState((drizzleState: any) => drizzleState.accounts)
    const {
        useCacheCall,
        useCacheSend
    } = drizzleReactHooks.useDrizzle()
    const balance = useCacheCall('piggyGame', 'balanceOf', accounts[0])
    const withdrawSend = useCacheSend('piggyGame', 'withdraw')
    async function submitWithdraw() {
        const baseUnits = piggyToBaseUnits(amount)
        withdrawSend.send(baseUnits)
        setAmount("0")
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