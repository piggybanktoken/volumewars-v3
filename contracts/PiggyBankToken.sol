// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;

import "./ERC20.sol";

contract PiggyBankToken is ERC20 {
    string public name = "PiggyBankToken";
    string public symbol = "PIGGY";
    uint256 public decimals = 5;
    uint256 public INITIAL_SUPPLY = 100000000000000000000000000;

    constructor() public {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
