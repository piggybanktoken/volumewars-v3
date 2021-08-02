import { useEffect, useMemo } from 'react'
import { Button, Modal, List, Header, Label } from 'semantic-ui-react'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { useAppSelector, useAppDispatch } from '../app/hooks'
import { closeAttackModal, selectAttackModalOpen, selectAttackModalTeam } from '../features/UISlice'
import { baseUnitsToPiggy } from '../app/utils'

export function AttackModal() {

    const accounts = drizzleReactHooks.useDrizzleState((drizzleState: any) => drizzleState.accounts)
    const dispatch = useAppDispatch()
    const open = useAppSelector(selectAttackModalOpen)
    const team = useAppSelector(selectAttackModalTeam)
    const {
        useCacheCall,
        useCacheSend
    } = drizzleReactHooks.useDrizzle()
    const rareChances = useCacheCall('piggyGame', 'getRareChances')
    const thresholds = useCacheCall('piggyGame', 'getThresholds')
    const balance = useCacheCall('piggyGame', 'balanceOf', accounts[0])
    const convertedBalance = useMemo(() => baseUnitsToPiggy(balance), [balance])
    const attackSend = useCacheSend('piggyGame', 'attack')



    async function attackTeam(amount: string) {
        attackSend.send(amount, team)
    }
    return (
        <Modal
            onClose={() => dispatch(closeAttackModal({}))}
            open={open}
        >
        <Modal.Header>Attack Team {team}</Modal.Header>
        <Modal.Content image>
            <Modal.Description>
            <Header size="medium" className="header-margin-1">
                Balance: {convertedBalance} War Pigs
            </Header>
            <Header size="medium" className="header-margin-2">
                Choose your attack size:
            </Header>
            <List>
                {thresholds && rareChances && Object.keys(thresholds).map(key => 
                <List.Item key={key}>
                    <Button onClick={()=> attackTeam(thresholds[key])}>{baseUnitsToPiggy(thresholds[key])} War Pigs</Button>
                    {rareChances[parseInt(key)-1] && <Label>1 in {rareChances[parseInt(key)-1]} Chances of getting a Rare NFT</Label>}
                </List.Item>
                )}
                
            </List>
            </Modal.Description>
        </Modal.Content>
        <Modal.Actions>
            <Button color='black' onClick={() => dispatch(closeAttackModal({}))}>Cancel</Button>
        </Modal.Actions>
        </Modal>
    )
}