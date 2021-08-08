import React, { useMemo } from 'react'
import { Card, Icon, Image } from 'semantic-ui-react'
import { drizzleReactHooks } from '@drizzle/react-plugin'
import { getTeamTokenData, baseUnitsToTokens } from "../app/utils"

// XXX Should this do its own damagePoints/image URL fetching?

export default function TeamDisplay(props: {
    team: string, ownTeam: boolean
}) {
    let {team, ownTeam} = props
    const {
        useCacheCall,
    } = drizzleReactHooks.useDrizzle()
    const damagePoints = useCacheCall('piggyGame', 'teamDamageOf', team)
    const [decimals, symbol, name] = useCacheCall(['piggyGame'], getTeamTokenData(team))
    const bnbPoints = useMemo(() => baseUnitsToTokens(damagePoints, "9"), [damagePoints])
    return (
        <Card>
            <Image src={"https://react.semantic-ui.com/images/avatar/large/matthew.png"} />
            <Card.Content>
                <Card.Header>{name}</Card.Header>
                <Card.Meta>
                    <span className='date'>{bnbPoints} damage points</span>
                </Card.Meta>
                <Card.Description>
                    <p>
                        {ownTeam ? "This is your team": "This is an opposing team"}
                    </p>
                </Card.Description>
            </Card.Content>
        </Card>
    )
}
