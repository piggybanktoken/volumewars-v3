import React, { useState, useEffect } from "react";
import ReactDOM from 'react-dom';
import { Button, Image, Search, Grid, Container, Dropdown, Segment, Divider, Icon, Label, Sidebar, Menu, Header } from 'semantic-ui-react'
import { TopBar } from './topBar'
import { useAppSelector, useAppDispatch } from '../app/hooks'
import { selectVisible, setMenuVisible } from '../features/UISlice'


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
  const numbers = [1, 2, 3, 4, 5]
  let row = numbers.map((n) =>
    <Grid.Column key={n}>
      <Segment>
        <Image src='https://pigtoken.finance/wp-content/uploads/2021/04/icon-pigg.png' size='small' />
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
  const visible = useAppSelector(selectVisible)
  const dispatch = useAppDispatch()
  return (
    <div>
      <TopBar />
      <Sidebar.Pushable>
        <Sidebar
          as={Menu}
          animation='overlay'
          icon='labeled'
          inverted
          vertical
          visible={visible}
          width='very wide'
          fluid
        >
          <Menu.Item as='a'>
            <Icon name='home' />
              Dashboard
            </Menu.Item>
          <Menu.Item as='a'>
            <Icon name='gamepad' />
              NFT Marketplace
            </Menu.Item>
          <Menu.Item as='a'>
            <Icon name='camera' />
              Statistics
            </Menu.Item>
          <Menu.Item as='a'>
            <Icon name='home' />
              NFT Dividends
            </Menu.Item>
          <Menu.Item as='a'>
            <Icon name='gamepad' />
              Re-Roll NFT
            </Menu.Item>
          <Menu.Item as='a'>
            <Icon name='camera' />
              Home
            </Menu.Item>

        </Sidebar>

        <Sidebar.Pusher>
      <Segment>

      actual content here
    <NFTArea />


      </Segment>
        </Sidebar.Pusher>
      </Sidebar.Pushable>

    </div>
  )
}
