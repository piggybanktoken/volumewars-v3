import React, { useState } from "react"
import { Grid, Button, Label, Header, Container, Input, Segment, Modal, Image } from 'semantic-ui-react'
import TeamDisplay from './teamDisplay'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { DepositModal } from './depositModal'
import { BuyModal } from './buyModal'
import { AttackModal } from './attackModal'

import { piggyToBaseUnits, baseUnitsToPiggy } from '../app/utils'
import { useAppSelector, useAppDispatch } from '../app/hooks'
import { openAttackModal, closeAttackModal } from '../features/UISlice'

export function War() {
    const drizzleState = drizzleReactHooks.useDrizzleState((drizzleState: {accounts: any}) => drizzleState)
    const {
        useCacheCall,
    } = drizzleReactHooks.useDrizzle()
    const accounts = drizzleReactHooks.useDrizzleState((state: any) => state.accounts)
    const balance = useCacheCall('piggyGame', 'balanceOf', accounts[0])
    const season = useCacheCall('piggyGame', 'currentSeason')
    const gameOpen = useCacheCall('piggyGame', 'isGameOpen')
    const convertedBalance = baseUnitsToPiggy(balance.toString())

    const dispatch = useAppDispatch()

    const teams = [1, 2, 3, 4, 5]
    const nteams = 5

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
                        <Header size="small" className="header-margin-2">
                            Deposit $PIGGY to get War Pigs, or buy War Pigs directly for BNB:
                        </Header>
                        <DepositModal /> <BuyModal />
                    </Segment>
                    <Segment>
                        <Grid columns={nteams} container={true}>
                            {teams.map((tnumber) =>
                                <Grid.Column key={tnumber}>
                                    <div>
                                        <TeamDisplay team={tnumber}/>
                                    </div>
                                    <Button fluid negative onClick={() => dispatch(openAttackModal(tnumber.toString()))}>Attack!</Button>
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
