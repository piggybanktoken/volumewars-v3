import React, { useState, useEffect } from "react";

import { Button, Card, Container, Segment } from 'semantic-ui-react'

import { NFTType, getNFTs } from '../features/nft'
import { NFTDisplay } from './nftDisplay'

export function NFTCollection() {
    /*
     * TODO:
     * - Display differently (don't filter, show all and scroll)
     */
    const [filter, setFilter] = useState(NFTType.Common)

    function filteredNFTs() {
        // XXX getNFTs side effects?
        const out = getNFTs().filter((nft) => nft.rarity == filter)
        console.log(out)
        return out
    }

    function NFTSelector() {
        return (
            <Container>
                <Button.Group size="large" fluid={true}>
                    <Button secondary={filter === NFTType.Common} onClick={() => setFilter(NFTType.Common)}>Common</Button>
                    <Button color="blue" secondary={filter === NFTType.Rare} onClick={() => setFilter(NFTType.Rare)}>Rare</Button>
                    <Button color="orange" secondary={filter === NFTType.Legendary} onClick={() => setFilter(NFTType.Legendary)}>Legendary</Button>
                </Button.Group>
            </Container>
        )
    }

    return (
        <div>
            <NFTSelector />
            <Segment>
                <Card.Group itemsPerRow={4}>
                    {filteredNFTs().map((nft =>
                        <NFTDisplay rarity={nft.rarity} name={nft.name} image={nft.image} />
                    ))}
                </Card.Group>
            </Segment>
        </div>
    )
}
