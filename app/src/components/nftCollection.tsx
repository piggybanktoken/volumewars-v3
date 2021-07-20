import React, { useState, useEffect } from "react";

import { Button, Image, Search, Grid, Card, Container, Dropdown, Segment, Divider, Icon, Label, Sidebar, Menu, Header } from 'semantic-ui-react'

import { NFTType } from '../features/nft'
import { NFTDisplay } from './nftDisplay'

export function NFTCollection() {
    const [filter, setFilter] = useState(NFTType.Common)

    const mocknfts = [
        {rarity: NFTType.Common,
        name: "awfaefa",
        image: "https://react.semantic-ui.com/images/avatar/large/matthew.png"},
        {rarity: NFTType.Common,
        name: "awdfsfsd",
        image: "https://react.semantic-ui.com/images/avatar/large/matthew.png"},
        {rarity: NFTType.Rare,
        name: "awdfsfsdddd",
        image: "https://react.semantic-ui.com/images/avatar/large/matthew.png"},
        {rarity: NFTType.Rare,
        name: "super cool nft",
        image: "https://react.semantic-ui.com/images/avatar/large/daniel.jpg"},
        {rarity: NFTType.Legendary,
        name: "the best",
        image: "https://react.semantic-ui.com/images/avatar/large/daniel.jpg"},
    ]

    function filteredNFTs() {
        const out = mocknfts.filter((nft) => nft.rarity == filter)
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
