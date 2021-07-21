// This type stuff is probably overkill but I might as well get some TS practice in - Smith
export enum NFTType {
    Common = 1,
    Rare,
    Legendary
}

export interface NFT {
    rarity: NFTType,
    name: string,
    image: string
}

export type NFTColor = "black" | "blue" | "orange" | "green"

export function NFTType2Name(t: NFTType) {
    if (t === NFTType.Common) return 'common'
    if (t === NFTType.Rare) return 'rare'
    if (t === NFTType.Legendary) return 'legendary'
    return 'unknown'
}

export function NFTType2Color(t: NFTType): NFTColor {
    if (t === NFTType.Common) return 'black'
    if (t === NFTType.Rare) return 'blue'
    if (t === NFTType.Legendary) return 'orange'
    return 'green'
}

export function getNFTs(): NFT[] {
    // TODO stub
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
    return mocknfts
}
