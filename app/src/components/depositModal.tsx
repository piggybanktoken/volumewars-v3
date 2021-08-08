import { useEffect, useState, useMemo } from 'react'
import { Button, Header, Image, Modal, Input } from 'semantic-ui-react'
import { approve } from "../app/piggy";
import  { gameAddress } from '../app/piggyGame'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { baseUnitsToTokens, tokenToBaseUnits } from '../app/utils';

export function DepositModal() {
    const [open, setOpen] = useState(false)
    const [amount, setAmount] = useState("0")
    const accounts = drizzleReactHooks.useDrizzleState((drizzleState: any) => drizzleState.accounts)
    const {
        useCacheSend,
        useCacheCall,
    } = drizzleReactHooks.useDrizzle()
    const depositSend = useCacheSend('piggyGame', 'deposit')
    const {0: userTokenBalance, 1: decimals, 2: symbol, 3: name} = useCacheCall('piggyGame', 'tokenInfo', accounts[0])
    const teamAddress = useCacheCall('piggyGame', 'teamOf', accounts[0])
    const tokenBalance = useMemo(() => baseUnitsToTokens(userTokenBalance, decimals), [userTokenBalance, decimals])
    
    async function submitDeposit() {
        const baseUnits = tokenToBaseUnits(amount, decimals)
        await approve(gameAddress, baseUnits, teamAddress)
        depositSend.send(baseUnits)
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
            trigger={<Button secondary>Deposit {name}</Button>}
        >
        <Modal.Header>Deposit</Modal.Header>
        <Modal.Content image>
            <Modal.Description>
            <Header>Your ${symbol} Balance: {tokenBalance}</Header>
            <Header>Deposit Amount</Header>
            <Input 
            action={{
                color: 'teal',
                labelPosition: 'right',
                icon: 'star',
                content: 'Max',
                onClick: () => setAmount(tokenBalance)
              }}
            value={amount} onChange={(e, d) => setAmount(d.value)} type="number" />
            <p>
                You will receive one War Pig per ${symbol}.
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