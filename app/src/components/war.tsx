import React, { useEffect, useMemo } from "react"
import { Grid, Button, Label, Header, Container, Input, Segment, Modal, Image } from 'semantic-ui-react'
import TeamDisplay from './teamDisplay'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { DepositModal } from './depositModal'
import { BuyModal } from './buyModal'
import { AttackModal } from './attackModal'
import { WithdrawModal } from "./withdrawModal"
import { baseUnitsToTokens } from '../app/utils'
import { useAppSelector, useAppDispatch } from '../app/hooks'
import { openAttackModal, closeAttackModal } from '../features/UISlice'

export function War() {
    // const drizzleState = drizzleReactHooks.useDrizzleState((drizzleState: {accounts: any}) => drizzleState)
    const {
        useCacheSend,
        useCacheCall,
    } = drizzleReactHooks.useDrizzle()
    const accounts = drizzleReactHooks.useDrizzleState((state: any) => state.accounts)
    const balance = useCacheCall('piggyGame', 'balanceOf', accounts[0])
    const season = useCacheCall('piggyGame', 'currentSeason')
    const hasJoined = useCacheCall('piggyGame', 'hasPlayerJoined', accounts[0])
    const gameOpen = useCacheCall('piggyGame', 'isGameOpen')
    const teamArray = useCacheCall('piggyGame', 'getActiveTeams')
    const ownTeam = useCacheCall('piggyGame', 'teamOf', accounts[0])
    const decimals = useCacheCall('piggyGame', 'tokenDecimals', accounts[0])
    const convertedBalance = useMemo(() => baseUnitsToTokens(balance, decimals), [balance, decimals])
    const joinSend = useCacheSend('piggyGame', 'join')
    const dispatch = useAppDispatch()

    const nteams = 5
    async function joinGame(team: string) {
        joinSend.send(team, {value: "10000000000000000"})
    }
    useEffect(() => {
        console.log(ownTeam)
    }, [])
    return (
        <div>
            <Segment>
                <Header size="huge" textAlign="center">War Room</Header>
                <Header size="medium" className="header-margin-1" textAlign="center">Season {season} is currently {gameOpen ? <span className='warEnabled'>open</span> : <span className='warDisabled'>closed</span>}</Header>
            </Segment>
            <Grid columns={1} container={true}>
                <Grid.Column textAlign="center">
                    <Segment>
                        <Header size="medium" className="header-margin-1">
                            Balance: {convertedBalance} War Pigs
                        </Header>
                        <WithdrawModal />
                        <Header size="small" className="header-margin-2">
                            Deposit tokens to get War Pigs, or buy War Pigs directly for BNB:
                        </Header>
                        <DepositModal /> <BuyModal /> 
                    </Segment>
                    {gameOpen && (!hasJoined) && ownTeam != "0" &&
                    <Segment>
                        <Header size="medium" className="header-margin-1">
                            Join The Game for 0.01 BNB
                        </Header>
                        <Button onClick={() => joinGame(ownTeam)}>Join</Button>
                    </Segment>}
                    <Segment>
                        <Grid columns={nteams} container={true}>
                            {teamArray && teamArray.map((tnumber: string) =>
                                <Grid.Column key={tnumber}>
                                    <div>
                                        <TeamDisplay team={tnumber} ownTeam={ownTeam == tnumber}/>
                                    </div>
                                    {ownTeam != "0" &&
                                    <Button disabled={ownTeam == tnumber} fluid negative onClick={() => dispatch(openAttackModal(tnumber))}>Attack!</Button>
                                    }
                                    {ownTeam == "0" &&
                                    <Button fluid negative onClick={() => joinGame(tnumber)}>Join</Button>
                                    }
                                </Grid.Column>
                            )}
                        </Grid>
                    </Segment>
                </Grid.Column>
            </Grid>
        <AttackModal />
        </div>
    )
}
