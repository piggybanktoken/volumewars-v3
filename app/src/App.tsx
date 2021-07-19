import React from 'react'
import { DrizzleContext } from "@drizzle/react-plugin"
import { Drizzle } from "@drizzle/store"
import drizzleOptions from "./drizzleOptions"
import { ViewDataComponent } from "./components/viewDataComponent"
import { TestComponent } from "./components/testComponent"

import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from "react-router-dom";


const drizzle = new Drizzle(drizzleOptions as any)

function App() {
  return (
    <Router>
      <div>
        <nav>
          <ul>
            <li>
              <Link to="/drizzle">Drizzle stuff</Link>
            </li>
            <li>
              <Link to="/test">Test</Link>
            </li>

          </ul>
        </nav>

        {/* A <Switch> looks through its children <Route>s and
            renders the first one that matches the current URL. */}
        <Switch>
          <Route path="/drizzle">
            <Content />
          </Route>
          <Route path="/test">
            <TestComponent />
          </Route>

        </Switch>
      </div>
    </Router>
  );
}

function Content() {
  return (
    <DrizzleContext.Provider drizzle={drizzle}>
      <DrizzleContext.Consumer>
        { (drizzleContext: any) => {
          const { drizzle, drizzleState, initialized } = drizzleContext;

          if (!initialized) {
            return "Loading..."
          }

          return (
            <ViewDataComponent drizzle={drizzle} drizzleState={drizzleState} />
          )
        }}
      </DrizzleContext.Consumer>
    </DrizzleContext.Provider>
  );
}



export default App;
