import React from 'react'
import { Card, Image } from 'semantic-ui-react'
import { NFTType, NFTType2Name, NFTType2Color } from '../features/nft'

export function NFTDisplay(props: {
    rarity: NFTType,
    name: string,
    image: string
}) {
    return (
        <Card color={NFTType2Color(props.rarity)}>
            <Image src={props.image} wrapped ui={false} />
            <Card.Content>
                <Card.Header>{props.name}</Card.Header>
                <Card.Meta>
                    <span className='date'>A {NFTType2Name(props.rarity)} NFT.</span>
                </Card.Meta>
                <Card.Description>
                    maybe there will be a blurb here about it
      </Card.Description>
            </Card.Content>
        </Card>
    )
}
