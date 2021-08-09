import React, { useState, useMemo, useEffect } from "react";

import { Button, Card, Container, Segment, Image, Header } from 'semantic-ui-react'

import { NFTType, getNFTs } from '../features/nft'
import { drizzleReactHooks } from '@drizzle/react-plugin'

enum Rarity {
    Common = 1,
    Rare = 2,
    Legendary = 3
}
interface NFT {
    id: number,
    set: number,
    num: number
    rarity: Rarity // 1 Common, 2
}
interface NFTData {
    amount: number,
    sets: Set<number>
    nfts: NFT[]
}
interface OrderedNFTs {
    [set: number]: {
        legendary: NFT[],
        normal: {
            [num: number]: NFT[]
        }
    }
}
function sortNFT(data: NFTData): OrderedNFTs {
    if (!data || data.amount == 0) return {}

    let ordered: OrderedNFTs = {}
    for (let item of data.nfts) {
        const currentSet = ordered[item.set] || {legendary: [], normal: {}}
        if (item.rarity == Rarity.Legendary) {
            currentSet.legendary.push(item)
        } else {
            const currentSetNormal = currentSet.normal[item.num] || []
            currentSetNormal.push(item)
            currentSet.normal[item.num] = currentSetNormal
        }
        ordered[item.set] = currentSet
    }
    return ordered
}
// function NFTSelector() {
//     return (
//         <Container>
//             <Button.Group size="large" fluid={true}>
//                 <Button secondary={filter === NFTType.Common} onClick={() => setFilter(NFTType.Common)}>Common</Button>
//                 <Button color="blue" secondary={filter === NFTType.Rare} onClick={() => setFilter(NFTType.Rare)}>Rare</Button>
//                 <Button color="orange" secondary={filter === NFTType.Legendary} onClick={() => setFilter(NFTType.Legendary)}>Legendary</Button>
//             </Button.Group>
//         </Container>
//     )
// }

export function NFTCollection() {

    const {
        useCacheSend,
        useCacheCall,
    } = drizzleReactHooks.useDrizzle()
    const accounts = drizzleReactHooks.useDrizzleState((state: any) => state.accounts)
    const balance = useCacheCall('piggyNFT', 'balanceOf', accounts[0])
    const {send, TX} = useCacheSend('piggyNFT', 'mint')
    const boosterPackBalance = useCacheCall('piggyGame', 'boosterPackBalanceOf', accounts[0])
    const unclaimedBoosterPackBalance = useCacheCall('piggyGame', 'unclaimedBoosterPacksOf', accounts[0])
    const unpackBoosterPack = useCacheSend('piggyGame', 'unpackBoosterPack')
    const claimBoosterPacks = useCacheSend('piggyGame', 'claimBoosterPacks')

    const [nextN, setN] = useState(1)
    function mintNFT(){
        send(accounts[0], 1, nextN, {"gas": 999999})
        setN(nextN+1)
    }
    function claimPacks() {
        claimBoosterPacks.send({"value": "2000000000000000"})
    }
    function unPack(){
        unpackBoosterPack.send()
    }
    const nftData: NFTData = useCacheCall(['piggyNFT'], (call: any) => {
        const amountStr = call('piggyNFT', 'balanceOf', accounts[0])
        const nfts: NFT[] = []
        const sets = new Set<number>()

        if (!amountStr) {return {amount: 0, nfts, sets}}
        const amount = parseInt(amountStr)
        
        for (let i = 0; i < amount; i++) {
            try {
                const {0: idStr, 1: setStr, 2: numberStr} = call('piggyNFT', 'dataOfTokenOfOwnerByIndex', accounts[0], i)
                const id = parseInt(idStr)
                const set = parseInt(setStr)
                const num = parseInt(numberStr)
                sets.add(set)
                const rarity = (num == 0 && Rarity.Legendary) || (num > 4 && Rarity.Rare) || Rarity.Common
                const parsedData: NFT = {id, set, num, rarity}
                nfts.push(parsedData)
            } catch {

            }
        }
        const result: NFTData = {amount, nfts, sets}
        return result
    })
    
    
    const sorted = useMemo(() => sortNFT(nftData), [nftData])
    const range = (start: number, stop: number, step: number) => Array.from({ length: (stop - start) / step + 1}, (_, i) => start + (i * step));

    
    function NFTDisplay({nft, nfts}: {nft: NFT, nfts: NFT[]}) {
        const {id, set, num, rarity} = nft
        const typeName = (rarity == Rarity.Legendary && "Legendary") || (rarity == Rarity.Rare && "Rare") || "Common"
        if (nfts.length == 0) {
            return (
                <Card color="grey">
                <Image src="https://ipfs.io/ipfs/QmSiy1FL3NkB8eRRyHDHwae5y3AVe3eaQoDCk3eg4SEKfD" wrapped />
                <Card.Content>
                    <Card.Header>Number {num}/7</Card.Header>
                    <Card.Meta>
                        <span className='date'>None Owned</span>
                    </Card.Meta>
                    <Card.Description>
                        You haven't won any NFT of this type yet.
                    </Card.Description>
                </Card.Content>
                </Card>
            )
        }
        return (
            <Card color="green">
                <Image src="https://ipfs.io/ipfs/QmSiy1FL3NkB8eRRyHDHwae5y3AVe3eaQoDCk3eg4SEKfD" wrapped />
                <Card.Content>
                    <Card.Header>Number {num}/7</Card.Header>
                    <Card.Meta>
                        <span className='date'>Season {set} ({typeName})</span>
                    </Card.Meta>
                    <Card.Description>
                        You own {nfts.length} NFTs of this type.
                    </Card.Description>
                </Card.Content>
            </Card>
        )
    }
    function SetDisplay({setId}: {setId: number}) {
        const {
            useCacheSend,
        } = drizzleReactHooks.useDrizzle()
        const forge = useCacheSend('piggyGame', 'forgeLegendary')
        function legendaryIngredients(): NFT[] | false {
            const ingredients: NFT[] = []
            for (let i = 1; i <= 7; i++) {
                const nftList = sorted[setId].normal[i]
                if (!nftList) {return false}
                ingredients.push(nftList[0])
            }
            return ingredients
        }
        function forgeLegendary(cards: NFT[]) {
            console.log(cards.map(nft => nft.id))
            console.log(cards.map(nft => nft.num))
            const arg = cards.map(nft => nft.id.toString())
            forge.send(arg)
            console.log(forge)
        }
        const ingredients = useMemo(() => legendaryIngredients(), [sorted])
        const season = useCacheCall('piggyGame', 'currentSeason')
        const claimLegendaryReward = useCacheSend('piggyGame', 'claimLegendaryReward')
        function claimReward(nftId: number, season: string) {
            claimLegendaryReward.send(nftId, season)
        }
        return (<>
                    <Segment>
                        <Header>Season {setId} Set</Header>
                        <Card.Group itemsPerRow={8}>
                            {sorted && range(1, 7, 1).map((n) => {
                                const normalList = sorted[setId].normal[n]
                                if (normalList) {
                                    return <NFTDisplay key={n} nft={normalList[0]} nfts={normalList}/>
                                } else {
                                    return <NFTDisplay key={n} nft={{id: 0, set: setId, num: n, rarity: Rarity.Common}} nfts={[]}/>
                                }
                            })}
                            {sorted &&  
                                <NFTDisplay key={0} nft={sorted[setId].legendary[0] || {id: 0, set: setId, num: 0, rarity: Rarity.Legendary}} nfts={sorted[setId].legendary} />
                            }
                        </Card.Group>
                    </Segment>
                    <Segment>
                    <Button disabled={ingredients == false} onClick={() => ingredients == false || forgeLegendary(ingredients)}>{ingredients == false ? "Cannot Forge Legendary" : "Forge Legendary"}</Button>
                    {sorted[setId].legendary.map((nft, i) => {
                        return <Button key={nft.id} onClick={() => claimReward(nft.id, season)}>Claim Legendary Rewards (NFT: {nft.id})</Button>
                    })}
                    </Segment>
                </>)
         }
    return (
        <div>
            <Segment><Button onClick={() => mintNFT()}>Mint NFT</Button>
                NFTs Owned: {balance}
            </Segment>
            <Segment><Button onClick={() => claimPacks()}>Claim Booster Packs</Button>
            Booster Packs Unclaimed: {unclaimedBoosterPackBalance}
            </Segment>
            <Segment><Button onClick={() => unPack()}>Open Booster Pack</Button>
                Booster Packs Owned: {boosterPackBalance}
            </Segment>
            {Object.keys(sorted).map((setId)=> 
                        <SetDisplay key={setId} setId={parseInt(setId)}/>
            )}
        </div>
    )
}
