import {useEffect, useState } from 'react'
import { Button, Modal, List } from 'semantic-ui-react'
import  { buyTokens } from '../app/piggyGame'
import { tokenQuote } from '../app/swap'

export function BuyModal() {
    const [open, setOpen] = useState(false)
    
    async function buyWarPigs(BNBAmount: number) {
        const [_BNBValue, minTokens] = await tokenQuote(BNBAmount)
        await buyTokens(BNBAmount.toString(), minTokens)
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
                    <Button onClick={()=> buyWarPigs(0.1)}>0.1 BNB</Button>
                </List.Item>
                <List.Item>
                    <Button onClick={()=> buyWarPigs(0.5)}>0.5 BNB</Button>
                </List.Item>
                <List.Item>
                    <Button onClick={()=> buyWarPigs(1)}>1 BNB</Button>
                </List.Item>
                <List.Item>
                    <Button onClick={()=> buyWarPigs(2)}>2 BNB</Button>
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