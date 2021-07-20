export enum NFTType {
    Common = 1,
    Rare,
    Legendary
}

export function NFTType2Name(t: NFTType) {
    if (t === NFTType.Common) return 'common'
    if (t === NFTType.Rare) return 'rare'
    if (t === NFTType.Legendary) return 'legendary'
    return 'unknown'
}

export function NFTType2Color(t: NFTType) {
    if (t === NFTType.Common) return 'black'
    if (t === NFTType.Rare) return 'blue'
    if (t === NFTType.Legendary) return 'orange'
    return 'green'

}
