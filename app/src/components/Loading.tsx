import React, { Component, Children } from 'react'

function Loading(props: {web3: any, drizzleStatus: any}) {
    if (props.web3.status === 'failed')
    {
      return(
        // Display a web3 warning.
        <main>
          <h1>⚠️</h1>
          <p>This browser has no connection to the Ethereum network. Please use the Chrome/FireFox extension MetaMask, or dedicated Ethereum browsers Mist or Parity.</p>
        </main>
      )
    }
    if (props.drizzleStatus.initialized)
    {
      // Load the dapp.
      return <div>Test</div>
    }
    return(
        // Display a loading indicator.
        <main>
          <h1>⚙️</h1>
          <p>Loading dapp...</p>
        </main>
      )
}


export default Loading