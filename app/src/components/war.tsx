import React, { useState } from "react";
import { Grid, Button, Label, Header, Container, Input, Segment, Modal, Image } from 'semantic-ui-react';
import { BalanceDisplay } from './balance';
import TeamDisplay from './teamDisplay';
import { Drizzle } from "@drizzle/store";
import { drizzleReactHooks } from '@drizzle/react-plugin'

// TODO unstub attack button
// TODO get and render teams
// TODO input validation
// - balance sufficient
// - not attacking own team

function WarEnabled() {
    // TODO stub
    const [war, setWar] = useState(true)
    return war
}

function WarText() {
    const war = WarEnabled()
    if (war) {
        return (<span className='warEnabled'>ENABLED</span>)
    } else {
        return (<span className='warDisabled'>DISABLED</span>)
    }
}

function RenderTeam(props: { team: number }) {
    // TODO stub
    return (
        <div>
            <TeamDisplay team={props.team}/>
        </div>
    )
}


export function War() {
    const drizzleState = drizzleReactHooks.useDrizzleState((drizzleState: {accounts: any}) => drizzleState)
    const {
        drizzle,
        useCacheCall,
        useCacheEvents,
        useCacheSend
    } = drizzleReactHooks.useDrizzle()

    enum AttackState {
        Closed = 1,
        Confirm,
        Wait
    }
    const [attackSize, setSize] = useState(0)
    const [attackTarget, setTarget] = useState(0)
    const [modalState, setModalState] = useState(AttackState.Closed)
    const teams = [1, 2, 3, 4, 5]
    const nteams = 5

    function startAttack(team: number) {
        setTarget(team)
        setModalState(AttackState.Confirm)
    }

    function confirmAttack() {
        // TODO stub
      setModalState(AttackState.Wait)
    }

    return (
        <div>
            <Segment>
                <Header size="huge" textAlign="center">War Room</Header>
                <Header size="medium" className="header-margin-1" textAlign="center">War is currently <WarText /></Header>
            </Segment>
            <Grid columns={1} container={true}>
                <Grid.Column textAlign="center">
                    <Segment>
                        <Header size="small" className="header-margin-1">
                            Balance:
                    </Header>
                        <BalanceDisplay drizzle={drizzle} drizzleState={drizzleState}/>
                        <Input placeholder='Attack Size' onChange={(e => setSize(parseInt(e.target.value)))} />
                    </Segment>

                    <Segment>
                        <Grid columns={nteams} container={true}>
                            {teams.map((tnumber) =>
                                <Grid.Column>
                                    <RenderTeam team={tnumber} />
                                    <Button fluid negative onClick={() => startAttack(tnumber)}>Attack!</Button>
                                </Grid.Column>
                            )}

                        </Grid>
                    </Segment>

                </Grid.Column>
            </Grid>

            <Modal
                onClose={() => setModalState(AttackState.Closed)}
                onOpen={() => setModalState(AttackState.Confirm)}
                open={modalState != AttackState.Closed}
            >
                <Modal.Header>Attack This Team with {attackSize} PIGGY?</Modal.Header>
                <Modal.Content>
                    {(modalState == AttackState.Confirm) &&
                        <Grid columns={3}>
                        <Grid.Column/>
                        <Grid.Column textAlign="center">
                        <RenderTeam team={attackTarget} />
                        </Grid.Column>
                        </Grid>
                    }
                    {(modalState == AttackState.Wait) &&
                        <p> Attack started! We will notify you when the attack finishes. </p>
                    }
                </Modal.Content>
                <Modal.Actions>
                    {(modalState == AttackState.Confirm) &&
                        <Button color='black' onClick={() => setModalState(AttackState.Closed)}>
                            Cancel
                     </Button>
                    }
                    {(modalState == AttackState.Confirm) &&
                        <Button
                            content="ATTACK!"
                            labelPosition='right'
                            icon='checkmark'
                            onClick={confirmAttack}
                            positive
                        />
                    }
                    {(modalState == AttackState.Wait) &&
                        <Button
                            content="Finish."
                            labelPosition='right'
                            icon='checkmark'
                            onClick={() => setModalState(AttackState.Closed)}
                            positive
                        />
                    }
                </Modal.Actions>
            </Modal>
        </div>
    )
}
