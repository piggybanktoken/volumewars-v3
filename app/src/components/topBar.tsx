import React, { useState } from "react";
import { Button, Image, Grid, Segment, Icon, Label, Menu, Container } from 'semantic-ui-react'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { useAppSelector, useAppDispatch } from '../app/hooks'
import { selectVisible, setMenuVisible } from '../features/UISlice'
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

function Balance() {
    const accounts = drizzleReactHooks.useDrizzleState((state: any) => state.accounts)
    const { useCacheCall } = drizzleReactHooks.useDrizzle()
    const balance = useCacheCall('piggyGame', 'balanceOf', accounts[0])
    function shortBalance() {
        if (balance) {
            return balance.toString().slice(0,-9).slice(0, -3)
        }
        return "0"
    }
    return (
        <span>
            War Pigs: {shortBalance()} K
        </span>
    )
}

export function TopBar() {
    const initialized = drizzleReactHooks.useDrizzleState((state: any) => state.drizzleStatus.initialized)
    const visible = useAppSelector(selectVisible)
    const dispatch = useAppDispatch()
    return (
        <Menu size='large'>
          <Container>
            <Menu.Item icon="angle double down" onClick={() => dispatch(setMenuVisible(!visible))}></Menu.Item>
            {initialized && <Menu.Item><Balance/></Menu.Item>}
            <Menu.Item position='right'>
                {initialized ? "Connected" : "Connect Wallet"}
            </Menu.Item>
          </Container>
        </Menu>
    )
}
