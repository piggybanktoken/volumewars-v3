import React, { useState } from "react";
import { Grid, Button, Label, Header, Container } from 'semantic-ui-react'

function PrizePool() {
    const [pool, setPool] = useState(149237934)
    return (<span> {pool} PIGGY</span>)
}

function Balance() {
    const [balance, setBalance] = useState(1234)
    return (
        <div>
            <Header size="large" className="header-margin-1">Your Balance:</Header>
            <Header size="medium" className="header-margin-1">{balance} PIGGY</Header>
            <Button.Group vertical>
                <Button color="pink">Deposit PIGGY</Button>
                <Button color="orange">Buy PIGGY</Button>
            </Button.Group>
        </div>
    )
}

function Team() {
    const [teamID, setTeam] = useState("asdfawefafsfa")
    const [teamDamage, setDamage] = useState(915139)
    return (
        <div>
            <Header size="large" className="header-margin-1">Your Team:</Header>
            <Header size="medium" className="header-margin-1">Team ID: {teamID}</Header>
            <Header size="medium" className="header-margin-1">Team Damage: {teamDamage}</Header>
        </div>
    )
}

export function Dashboard() {
    return (
        <div>
            <Header size='huge' textAlign="center" className="header-margin-1">Dashboard</Header>
            <Header size='large' textAlign="center" className="header-margin-1">Current Price Pool: <PrizePool /></Header>
        <br />
            <Grid columns={2} container={true}>
                <Grid.Column textAlign="center">
                    <Team />
                </Grid.Column>

                <Grid.Column textAlign="center">
                    <Balance />
                </Grid.Column>
            </Grid>

        </div>
    )
}
