import React, { useContext } from 'react'
import { ViewDataComponent } from "./components/viewDataComponent"
import { Dashboard } from "./components/Dashboard"
import { NFTCollection } from "./components/nftCollection"
import { War } from "./components/war"
import { TopBar } from "./components/topBar"
import { Button, Image, Search, Grid, Container, Dropdown, Segment, Divider, Icon, Label, Sidebar, Menu, Header } from 'semantic-ui-react'
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from "react-router-dom";
import { useAppSelector, useAppDispatch } from './app/hooks'
import { selectVisible, setMenuVisible } from './features/UISlice'

import { drizzleReactHooks } from '@drizzle/react-plugin'


function App() {
  const visible = useAppSelector(selectVisible)
  const dispatch = useAppDispatch()
  function closeMenu() { dispatch(setMenuVisible(false)) }

  const initialized = drizzleReactHooks.useDrizzleState((state: any) => state.drizzleStatus.initialized)
  return (
    <div>
      <Router>
        <TopBar />
        <Sidebar.Pushable className="burgerMenu">
          <Sidebar
            as={Menu}
            animation='overlay'
            icon='labeled'
            inverted
            vertical
            visible={visible}
            width='very wide'
            fluid
            size="huge"
          >
              <Menu.Item as={Link} to="/home" onClick={closeMenu}>
                Home
              </Menu.Item>
              <Menu.Item as={Link} to="/drizzle" onClick={closeMenu}>
                Drizzle
              </Menu.Item>
              <Menu.Item as={Link} to="/war" onClick={closeMenu}>
                War
              </Menu.Item>
              <Menu.Item as={Link} to="/nfts" onClick={closeMenu}>
                NFTs
              </Menu.Item>
          </Sidebar>

          <Sidebar.Pusher>
            <Switch>
              <Route path="/">
                {initialized && <War />}
              </Route>
              <Route path="/drizzle">
                {initialized && <ViewDataComponent />}
              </Route>
              <Route path="/home">
                {initialized && <Dashboard />}
              </Route>
              <Route path="/war">
                {initialized && <War/>}
              </Route>
              <Route path="/nfts">
                {initialized && <NFTCollection />}
              </Route>
            </Switch>
          </Sidebar.Pusher>
        </Sidebar.Pushable>
      </Router>
    </div>
  )
}

export default App;
