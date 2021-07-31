import React, { useEffect, useState, useContext } from "react";
import { newContextComponents } from "@drizzle/react-components";
import { Drizzle } from "@drizzle/store";
import { buyTokensAPI, PANCAKE_ROUTER_V2 } from "../app/swap";
import { balanceOf, approve, tokenAddress, transfer } from "../app/piggy";
import  { deposit, withdraw, buyTokens, attack, gameBalanceOf } from '../app/piggyGame'
import { gameAddress, nftAddress } from "../app/piggyGame";
import { Button, Checkbox, Form } from 'semantic-ui-react'
import { drizzleReactHooks } from '@drizzle/react-plugin'

export function Home() {
    return (
        <div></div>
    )
}