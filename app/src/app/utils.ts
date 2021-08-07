import BN from 'bn.js'


export function piggyToBaseUnits(piggyNumber: string): string {
    return new BN(piggyNumber).mul(new BN(10**9)).toString()
}
export function baseUnitsToPiggy(piggyNumber: string): string {
    if (!piggyNumber) return "0"
    return new BN(piggyNumber).div(new BN(10**9)).toString()
}

export function tokenToBaseUnits(amount: string, decimals: string): string {
    if (!amount || !decimals) return "0"
    return new BN(amount).mul(new BN(decimals)).toString()
}
export function baseUnitsToTokens(amount: string, decimals: string): string {
    if (!amount || !decimals) return "0"
    return new BN(amount).div(new BN(decimals)).toString()
}