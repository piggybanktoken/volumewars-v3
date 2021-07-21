import React from 'react'
import { Card, Icon, Image } from 'semantic-ui-react'

// XXX Should this do its own damagePoints/image URL fetching?

export default function TeamDisplay(props: {
    team: number,
    url?: string,
    damagePoints?: number
}) {
    let { team, url, damagePoints } = props
    if (!url)
        url = "https://react.semantic-ui.com/images/avatar/large/matthew.png"
    if (!damagePoints)
        damagePoints = 1874

    return (
        <Card>
            <Image src={url} />
            <Card.Content>
                <Card.Header>Team {team}</Card.Header>
                <Card.Meta>
                    <span className='date'>{damagePoints} damage points</span>
                </Card.Meta>
                <Card.Description>
                    <p>
                        should there be something here?
                    </p>
                </Card.Description>
            </Card.Content>
        </Card>
    )
}
