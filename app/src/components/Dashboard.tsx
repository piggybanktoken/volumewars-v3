import React, { useState, useEffect } from "react"
import { Grid, Header } from 'semantic-ui-react'
import { BalanceDisplay, DepositButton } from './balance'
import TeamDisplay from './teamDisplay'
import { Drizzle } from "@drizzle/store";

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
    return (
        <TeamDisplay team={teamID}
                     damagePoints={teamDamage}/>
    )
}

export function Dashboard({ drizzle, drizzleState }: {drizzle: Drizzle, drizzleState: any}) {
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
