import React, { useState } from "react";
import { Grid, Button, Label, Header, Container } from 'semantic-ui-react';

function WarEnabled() {
    const [war, setWar] = useState(true)
    return (<span> {war} PIGGY</span>)
}

export function War() {
    return (
        <div>
            <Header size="huge" textAlign="center">War Room</Header>

            </div>
    )
}
