import React, { useState } from "react";
import ReactDOM from 'react-dom';
import { Button, Image, Search, Grid, Container, Dropdown, Segment, Divider, Icon, Label } from 'semantic-ui-react'
import { Header } from './topBar'

function NFTScreen() {
    return (
        <div>
            <Header/>
        </div>

    )
}

function NFTMiddleBar() {
    return (
            <Container>
            <Button.Group size="large" fluid={true}>
            <Button>Common</Button>
            <Button color="blue">Rare</Button>
            <Button color="orange">Legendary</Button>
            </Button.Group>
            </Container>
    )
}

function NFTArea() {
    const numbers = [1,2,3,4,5]
    let row = numbers.map((n) =>
        <Grid.Column key={n}>
        <Segment>
        <Image src='https://pigtoken.finance/wp-content/uploads/2021/04/icon-pigg.png' size='small'/>
        </Segment>
        </Grid.Column>
        );
   return (
       <Grid columns={5} container={true}>
       {row}
       {row}
       {row}
       {row}
       </Grid>
   )

}

export function TestComponent() {
    return (
        <div>
            <NFTScreen />
            </div>
    )
}
