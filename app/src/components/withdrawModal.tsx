import {useEffect, useState, useMemo } from 'react'
import { Button, Header, Modal, Input } from 'semantic-ui-react'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { tokenToBaseUnits, baseUnitsToTokens, getUserTokenData } from '../app/utils';

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

    const [_tokenBalance, decimals, symbol, name] = useCacheCall(['piggyGame'], getUserTokenData(accounts[0]))

    async function submitWithdraw() {
        const baseUnits = tokenToBaseUnits(amount, decimals)
        withdrawSend.send(baseUnits)
        setAmount("0")
    }
    const warPigsBalance = useMemo(() => baseUnitsToTokens(balance, decimals), [balance, decimals])

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
            <Header>Your War Pigs Balance: {warPigsBalance}</Header>
            <Header>Withdraw Amount</Header>
            <Input 
            action={{
                color: 'teal',
                labelPosition: 'right',
                icon: 'star',
                content: 'All',
                onClick: () => setAmount(warPigsBalance)
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