import {useEffect, useState } from 'react'
import { Button, Modal, List } from 'semantic-ui-react'
import  { buyTokens } from '../app/piggyGame'
import { tokenQuote } from '../app/swap'
import { drizzleReactHooks } from '@drizzle/react-plugin'

export function BuyModal() {
    const [open, setOpen] = useState(false)
    const {
        useCacheSend,
        useCacheCall,
    } = drizzleReactHooks.useDrizzle()
    const {send, TX} = useCacheSend('piggyGame', 'buyTokens')
    async function buyWarPigs(BNBAmount: number) {
        const [BNBValue, minTokens] = await tokenQuote(BNBAmount)
        send(minTokens, {"value": BNBValue})
        // await buyTokens(BNBAmount.toString(), minTokens)
    }
    
    return (
        <Modal
            onClose={() => setOpen(false)}
            onOpen={() => setOpen(true)}
            open={open}
            trigger={<Button secondary>Buy War Pigs</Button>}
        >
        <Modal.Header>Buy War Pigs</Modal.Header>
        <Modal.Content image>
            <Modal.Description>
            <List>
                <List.Item>
                    <Button onClick={()=> buyWarPigs(0.01)}>0.01 BNB</Button>
                </List.Item>
                <List.Item>
                    <Button onClick={()=> buyWarPigs(0.05)}>0.05 BNB</Button>
                </List.Item>
                <List.Item>
                    <Button onClick={()=> buyWarPigs(0.1)}>0.1 BNB</Button>
                </List.Item>
                <List.Item>
                    <Button onClick={()=> buyWarPigs(0.2)}>0.2 BNB</Button>
                </List.Item>
            </List>
            <p>
                VolumeWars will buy $PIGGY with BNB from PancakeSwap and <br></br>
                credit them to your VolumeWars account as War Pigs.<br></br>
                This lets you avoid paying the $PIGGY transaction fee twice.
            </p>
            </Modal.Description>
        </Modal.Content>
        <Modal.Actions>
            <Button color='black' onClick={() => setOpen(false)}>
            Cancel
            </Button>
        </Modal.Actions>
        </Modal>
    )
}