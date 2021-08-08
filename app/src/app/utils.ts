import BN from 'bn.js'

function isZero(str: string) {
    if (!str) return true;
    if (str == "0") return true;
    return false;
}
export function piggyToBaseUnits(piggyNumber: string): string {
    return new BN(piggyNumber).mul(new BN(10**9)).toString()
}
export function baseUnitsToPiggy(piggyNumber: string): string {
    if (!piggyNumber) return "0"
    return new BN(piggyNumber).div(new BN(10**9)).toString()
}

export function tokenToBaseUnits(amount: string, decimals: string): string {
    if (isZero(amount) || isZero(decimals)) return "0"
    return new BN(amount).mul(new BN(decimals)).toString()
}
export function baseUnitsToTokens(amount: string, decimals: string): string {
    if (isZero(amount) || isZero(decimals)) return "0"
    return new BN(amount).div(new BN(decimals)).toString()
}

export function getUserTokenData(account: string) { 
    return (call: any) => {
        const team = call('piggyGame', 'teamOf', account)
        if (!team) {
            return ["0", "0", "", ""]
        }
        const result = call('piggyGame', 'tokenInfo', team)
        if (!result) {
            return ["0", "0", "", ""]
        }
        const {0: decimals, 1: symbol, 2: name} = result;

        const tokenBalance = call('piggyGame', 'tokenBalanceOf', account)
        if (!tokenBalance) {
            return ["0", decimals as string, symbol as string, name as string]
        }
        return [tokenBalance as string, decimals as string, symbol as string, name as string]
    }
}

export function getTeamTokenData(team: string) { 
    return (call: any) => {
        if (!team) {
            return ["0", "", ""]
        }
        const result = call('piggyGame', 'tokenInfo', team)
        if (!result) {
            return ["0", "", ""]
        }
        const {0: decimals, 1: symbol, 2: name} = result;
        return [decimals as string, symbol as string, name as string]
    }
}