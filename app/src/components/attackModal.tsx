import {useEffect, useState } from 'react'
import { Button, Modal, List } from 'semantic-ui-react'
import  { buyTokens } from '../app/piggyGame'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { tokenQuote } from '../app/swap'
import { useAppSelector, useAppDispatch } from '../app/hooks'
import { openAttackModal, closeAttackModal, selectAttackModalOpen, selectAttackModalTeam } from '../features/UISlice'

export function AttackModal() {

    const accounts = drizzleReactHooks.useDrizzleState((drizzleState: any) => drizzleState.accounts)
    const dispatch = useAppDispatch()
    const open = useAppSelector(selectAttackModalOpen)
    const team = useAppSelector(selectAttackModalTeam)

    async function attackTeam(BNBAmount: number) {
        const [_BNBValue, minTokens] = await tokenQuote(BNBAmount)
        await buyTokens(BNBAmount.toString(), minTokens)
    }
    return (
        <Modal
            onClose={() => dispatch(closeAttackModal({}))}
            open={open}
        >
        <Modal.Header>Attack Team {team}</Modal.Header>
        <Modal.Content image>
            <Modal.Description>
            <List>
                <List.Item>
                    <Button onClick={()=> attackTeam(0.1)}>0.1 BNB</Button>
                </List.Item>
            </List>
            </Modal.Description>
        </Modal.Content>
        <Modal.Actions>
            <Button color='black' onClick={() => dispatch(closeAttackModal({}))}>Cancel</Button>
        </Modal.Actions>
        </Modal>
    )
}