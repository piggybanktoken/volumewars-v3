import { NFTCollection } from "./components/nftCollection"
import { War } from "./components/war"
import { TopBar } from "./components/topBar"
import { Sidebar, Menu } from 'semantic-ui-react'
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
              <Menu.Item as={Link} to="/" onClick={closeMenu}>
                War
              </Menu.Item>
              <Menu.Item as={Link} to="/nfts" onClick={closeMenu}>
                NFTs
              </Menu.Item>
          </Sidebar>

          <Sidebar.Pusher>
            <Switch>
            <Route path="/nfts">
              {initialized && <NFTCollection />}
            </Route>
            <Route path="/">
                {initialized && <War/>}
            </Route>
             
            </Switch>
          </Sidebar.Pusher>
        </Sidebar.Pushable>
      </Router>
    </div>
  )
}

export default App;
