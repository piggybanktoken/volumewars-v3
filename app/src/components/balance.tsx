import React, { useState } from "react";
import { Header, Button } from 'semantic-ui-react';

/*
 * TODO:
 * - Hook up to smart contract
 */

function BalanceDisplay() {
    // TODO stub
    const [balance, setBalance] = useState(1234)
    return (
        <div>
            <Header size="medium" className="header-margin-1">{balance} PIGGY</Header>
        </div>
    )
}

function DepositButton() {
    return (
        <Button.Group vertical>
            <Button color="pink">Deposit PIGGY</Button>
            <Button color="orange">Buy PIGGY</Button>
        </Button.Group>
    )
}

export { BalanceDisplay, DepositButton }
