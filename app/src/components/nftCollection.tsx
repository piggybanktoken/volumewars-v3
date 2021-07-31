import React, { useState, useEffect, useContext } from "react";

import { Button, Card, Container, Segment, Image } from 'semantic-ui-react'

import { NFTType, getNFTs } from '../features/nft'
import { drizzleReactHooks } from '@drizzle/react-plugin'

interface NFT {
    id: number,
    set: number,
    num: number
    rarity: 1 | 2 | 3
}
interface NFTData {
    amount: number,
    nfts: NFT[]
}

export function NFTCollection() {
    /*
     * TODO:
     * - Display differently (don't filter, show all and scroll)
     */
    const [filter, setFilter] = useState(NFTType.Common)

    const {
        useCacheSend,
        useCacheCall,
    } = drizzleReactHooks.useDrizzle()
    const accounts = drizzleReactHooks.useDrizzleState((state: any) => state.accounts)
    const balance = useCacheCall('piggyNFT', 'balanceOf', accounts[0])
    const {send, TX} = useCacheSend('piggyNFT', 'mint')
    // function filteredNFTs() {
    //     // XXX getNFTs side effects?
    //     const out = getNFTs().filter((nft) => nft.rarity == filter)
    //     console.log(out)
    //     return out
    // }

    
    const [nextN, setN] = useState(1)
    function mintNFT(){
        send(accounts[0], 1, nextN, {"gas": 999999})
        setN(nextN+1)
    }
    const nftData: NFTData = useCacheCall(['piggyNFT'], (call: any) => {
        const amountStr = call('piggyNFT', 'balanceOf', accounts[0])
        if (!amountStr) {return {amount: 0, nfts: []}}
        const amount = parseInt(amountStr)
        const nfts = []
        for (let i = 0; i < amount; i++) {
            try {
                const {0: idStr, 1: setStr, 2: numberStr} = call('piggyNFT', 'dataOfTokenOfOwnerByIndex', accounts[0], i)
                const id = parseInt(idStr)
                const set = parseInt(setStr)
                const num = parseInt(numberStr)
                const rarity = (num == 0 && 3) || (num > 4 && 2) || 1
                const parsedData: NFT = {id, set, num, rarity}
                nfts.push(parsedData)
            } catch {

            }
        }
        return {amount, nfts}
    })
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
    function NFTDisplay({id, set, num, rarity}: NFT) {

        const typeName = (rarity == 3 && "Legendary") || (rarity == 2 && "Rare") || "Common"
        return (
            <Card color="green">
                <Image src="https://ipfs.io/ipfs/QmSiy1FL3NkB8eRRyHDHwae5y3AVe3eaQoDCk3eg4SEKfD" wrapped />
                <Card.Content>
                    <Card.Header>Number {num}/7</Card.Header>
                    <Card.Meta>
                        <span className='date'>Season {set} ({typeName})</span>
                    </Card.Meta>
                    <Card.Description>
                        Collect all 7 NFTs from this season to forge them into a Legendary NFT
                    </Card.Description>
                </Card.Content>
            </Card>
        )
    }
    return (
        <div>
            <NFTSelector></NFTSelector>
            <Segment>
                <Button onClick={() => mintNFT()}>Mint NFT</Button>
                {balance}
                <Card.Group itemsPerRow={4}>
                    {nftData && nftData.amount > 0 && nftData.nfts.map(({id, set, num, rarity}) => 
                        <NFTDisplay key={id} id={id} set={set} num={num} rarity={rarity} />
                    )}
                </Card.Group>
            </Segment>
        </div>
    )
}
