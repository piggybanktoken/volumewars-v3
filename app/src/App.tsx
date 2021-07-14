import React from 'react'
import { DrizzleContext } from "@drizzle/react-plugin"
import { Drizzle } from "@drizzle/store"
import drizzleOptions from "./drizzleOptions"
import { ViewDataComponent } from "./components/viewDataComponent"

const drizzle = new Drizzle(drizzleOptions as any)

function App() {
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
