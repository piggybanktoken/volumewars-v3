import React, { useState } from "react";
import { Button, Image, Grid, Segment, Icon, Label } from 'semantic-ui-react'
import NavMenu from "./menu";

/*
 * TODO:
 * - Hook up to smart contract
 * - Does not work well on small viewports
 */

function Username() {
    const [name, setName] = useState('anonymous')
    return (
        <Label image size="big">
            <UserProfilePicture />
            {name}
        </Label>
    )
}

function Level() {
    const [level, setLevel] = useState(0)
    return (
        <Label size="big">
            {level}
        </Label>
    )
}

function UserIndicator() {
    return (
        <div>
            <Username />
            <Level />
        </div>
    )
}

function ConnectWalletButton() {
    return (
        <span>
            <Button size='large' fluid={true}
                icon labelPosition='right'
                onClick={() => "TODO"}>
                Connect Wallet <Icon name='bitcoin' />
            </Button>
        </span>
    )
}

function UserProfilePicture() {
    const [url, setURL] = useState('https://pigtoken.finance/wp-content/uploads/2021/04/icon-pigg.png')
    return (
        <Image src={url} size='small' />
    )
}

export function TopBar() {
    return (
        <Segment>
            <Grid columns={4} container={true}>
                <Grid.Column key={5} width="1" verticalAlign='middle'><NavMenu /> </Grid.Column>
                <Grid.Column key={2} floated='left' verticalAlign='middle'>
                    <UserIndicator />
                </Grid.Column>
                <Grid.Column key={3} floated='right' verticalAlign='middle'><ConnectWalletButton /></Grid.Column>
            </Grid>
        </Segment>
    )
}
