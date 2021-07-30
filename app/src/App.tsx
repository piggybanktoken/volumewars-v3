import React from 'react'
import { DrizzleContext } from "@drizzle/react-plugin"
import { Drizzle } from "@drizzle/store"
import drizzleOptions from "./drizzleOptions"
import { ViewDataComponent } from "./components/viewDataComponent"
import { TestComponent } from "./components/testComponent"
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

const drizzle = new Drizzle(drizzleOptions as any)

function App() {
  const visible = useAppSelector(selectVisible)
  const dispatch = useAppDispatch()
  function closeMenu() { dispatch(setMenuVisible(false)) }
  return (
    <DrizzleContext.Provider drizzle={drizzle}>
      <DrizzleContext.Consumer>
        {(drizzleContext: any) => {
          const { drizzle, drizzleState, initialized } = drizzleContext;

          if (!initialized) {
            return "Loading..."
          }


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
                    <Link to="/drizzle" onClick={closeMenu}>
                      <Menu.Item as='a'>
                        Drizzle
                      </Menu.Item>
                    </Link>

                    <Link to="/home" onClick={closeMenu}>
                      <Menu.Item as='a'>
                        Home
                      </Menu.Item>
                    </Link>

                    <Link to="/war" onClick={closeMenu}>
                      <Menu.Item as='a'>
                        War
                      </Menu.Item>
                    </Link>

                    <Link to="/nfts" onClick={closeMenu}>
                      <Menu.Item as='a'>
                        NFT Collection
                      </Menu.Item>
                    </Link>
                  </Sidebar>

                  <Sidebar.Pusher>
                    <Switch>
                      <Route path="/drizzle">
                        <ViewDataComponent drizzle={drizzle} drizzleState={drizzleState} />
                      </Route>
                      <Route path="/home">
                        <Dashboard drizzle={drizzle} drizzleState={drizzleState} />
                      </Route>
                      <Route path="/war">
                        <War drizzle={drizzle} drizzleState={drizzleState}/>
                      </Route>
                      <Route path="/nfts">
                        <NFTCollection />
                      </Route>
                    </Switch>
                  </Sidebar.Pusher>
                </Sidebar.Pushable>
              </Router>
            </div>
          )
        }}
      </DrizzleContext.Consumer>
    </DrizzleContext.Provider>
  );

}

export default App;
