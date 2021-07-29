// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract piggyNFT is ERC721PresetMinterPauserAutoId {

    constructor(address game) ERC721PresetMinterPauserAutoId("VolumeWars NFT", "VW", "token") {
        grantRole(MINTER_ROLE, game);
    }
}

