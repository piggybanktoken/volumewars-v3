import { useState } from "react"
import { Grid, Header } from 'semantic-ui-react'
import { BalanceDisplay, DepositButton } from './balance'

import { drizzleReactHooks } from '@drizzle/react-plugin'

/*
 * TODO:
 * - Hook up to smart contract
 */

function PrizePool() {
    const [pool, setPool] = useState(149237934)
    return (<span> {pool} PIGGY</span>)
}

function Team() {
    const [teamID, setTeam] = useState(2)
    const [teamDamage, setDamage] = useState(915139)
    return <div></div>
}

export function Dashboard() {
    const drizzleState = drizzleReactHooks.useDrizzleState((drizzleState: {accounts: any}) => drizzleState)
    const {
        drizzle,
        useCacheCall,
        useCacheEvents,
        useCacheSend
    } = drizzleReactHooks.useDrizzle()
    return (
        <div>
            <Header size='huge' textAlign="center" className="header-margin-1">Dashboard</Header>
            <Header size='large' textAlign="center" className="header-margin-1">Current Price Pool: <PrizePool /></Header>
            <br />
            <Grid columns={2} container={true}>
                <Grid.Column textAlign="center">
                    <Header size="large" className="header-margin-1">Your Team:</Header>
                    <Team />
                </Grid.Column>

                <Grid.Column textAlign="center">
                    <Header size="large" className="header-margin-1">Your Balance:</Header>
            <BalanceDisplay drizzle={drizzle} drizzleState={drizzleState}/>
                    <DepositButton />
                </Grid.Column>
            </Grid>

        </div>
    )
}
