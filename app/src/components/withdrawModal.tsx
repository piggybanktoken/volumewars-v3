import {useEffect, useState, useMemo } from 'react'
import { Button, Header, Modal, Input } from 'semantic-ui-react'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { tokenToBaseUnits, baseUnitsToTokens } from '../app/utils';

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
    const {0: _tokenBalance, 1: decimals, 2: symbol, 3: name} = useCacheCall('piggyGame', 'tokenInfo', accounts[0])


    async function submitWithdraw() {
        const baseUnits = tokenToBaseUnits(amount, decimals)
        withdrawSend.send(baseUnits)
        setAmount("0")
    }
    const tokenBalance = useMemo(() => baseUnitsToTokens(balance, decimals), [balance, decimals])

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
        <Modal.Header>Withdraw {name}</Modal.Header>
        <Modal.Content image>
            <Modal.Description>
            <Header>Your War Pigs Balance: {tokenBalance}</Header>
            <Header>Withdraw Amount</Header>
            <Input 
            action={{
                color: 'teal',
                labelPosition: 'right',
                icon: 'star',
                content: 'All',
                onClick: () => setAmount(tokenBalance)
              }}
            value={amount} onChange={(e, d) => setAmount(d.value)} type="number" />
            <p>
                You will receive one ${symbol} per War Pig.
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