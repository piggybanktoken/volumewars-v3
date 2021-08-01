import BN from 'bn.js'


export function piggyToBaseUnits(piggyNumber: string): string {
    return new BN(piggyNumber).mul(new BN(10**9)).toString()
}
export function baseUnitsToPiggy(piggyNumber: string): string {
    if (!piggyNumber) return "0"
    return new BN(piggyNumber).div(new BN(10**9)).toString()
}