import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'
import { store } from './app/store'
import { Provider } from 'react-redux'
import * as serviceWorker from './serviceWorker'
import drizzleOptions from "./drizzleOptions"
import { DrizzleContext } from "@drizzle/react-plugin"
import { Drizzle } from "@drizzle/store"
import { drizzleReactHooks } from '@drizzle/react-plugin'

import 'semantic-ui-css/semantic.min.css'
import './style.css'

const drizzle = new Drizzle(drizzleOptions as any);

export const DrizzleCtx = React.createContext(DrizzleContext)

ReactDOM.render(
    <Provider store={store}>
      <drizzleReactHooks.DrizzleProvider drizzle={drizzle}>
        <App />
      </drizzleReactHooks.DrizzleProvider>
    </Provider>,
  document.getElementById('root')
)

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister()
