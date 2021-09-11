// contracts/NFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract piggyNFT is
    Context,
    AccessControlEnumerable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable
{
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _tokenIdTracker;

    string private _baseTokenURI;

    struct NFTMetadata {
        uint16 set;
        uint8 number;
    }

    mapping(uint256 => NFTMetadata) metadata;

    struct SetMetadata {
        uint8 totalCards;
        bool enabled;
    }

    mapping(uint16 => SetMetadata) sets;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(
        address game
    ) ERC721("VolumeWars NFT", "VW") {
        _baseTokenURI = "volumewars-";

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        grantRole(MINTER_ROLE, game);
    }

    function metadataOf(uint256 id) external view returns (uint16, uint8) {
        return (metadata[id].set, metadata[id].number);
    }
    function dataOfTokenOfOwnerByIndex(address owner, uint256 id) external view returns (uint256, uint16, uint8) {
        uint256 tokenId = tokenOfOwnerByIndex(owner, id);
        return (tokenId, metadata[tokenId].set, metadata[tokenId].number);
    }
    function totalCardsOf(uint16 id) external view returns (uint8) {
        return sets[id].totalCards;
    }
    function addSet(uint16 set, uint8 number) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "RewardNFT: must have minter role to add sets");
        require(sets[set].enabled == false, "Set already exists");
        sets[set].totalCards = number;
        sets[set].enabled = true;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function forgeBurn(uint256 id) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "RewardNFT: must have minter role to mint");
        _burn(id);
    }
    /**
     * @dev Creates a new token for `to`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint16 set, uint8 number) external virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "RewardNFT: must have minter role to mint");
        require(sets[set].enabled, "RewardNFT: Set does not exist");
        require(number <= sets[set].totalCards, "RewardNFT: Card does not exist in set");
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _safeMint(to, _tokenIdTracker.current());
        metadata[_tokenIdTracker.current()].set = set;
        metadata[_tokenIdTracker.current()].number = number;
        _tokenIdTracker.increment();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
