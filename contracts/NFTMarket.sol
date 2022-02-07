// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./NFT.sol";

contract NFTMarketplace {
  uint256 public listingCounter;
  mapping (uint256 => Listing) public listings;
  mapping (uint16 => mapping(uint8 => uint256[])) cardListings;
  mapping (address => uint256[]) sellerListings;

  piggyNFT nft;
  IBEP20 token;

  struct Listing {
    uint256 listingId;
    uint256 id;
    address seller;
    uint256 price;
    uint16 set;
    uint8 number;
    bool enabled;
  }

  event NewListing(
    uint256 listingId,
    uint256 id,
    address indexed seller,
    uint256 price,
    uint16 indexed set,
    uint8 indexed number
  );

  event Sale(uint256 listingId, uint256 indexed id, address indexed newOwner, address indexed seller);
  event ListingCancelled(uint256 listingId, uint256 indexed id, address indexed owner);
  event ListingPriceChanged(uint256 listingId, uint256 indexed id, address indexed owner, uint256 newPrice);

  constructor(address nftAddress, address tokenAddress) {
    nft = piggyNFT(nftAddress);
    token = IBEP20(tokenAddress);
  }

  function getListing(uint256 _listingId) external view returns (
      uint256 listingId,
      uint256 id,
      address seller,
      uint256 price,
      uint16 set,
      uint8 number,
      bool enabled
    ) {

    Listing storage listing = listings[_listingId];
    return (
      listing.listingId,
      listing.id,
      listing.seller,
      listing.price,
      listing.set,
      listing.number,
      listing.enabled);
  }

  function getListingByCard(uint16 _set, uint8 _number, uint256 index) external view returns (
      uint256 listingId,
      uint256 id,
      address seller,
      uint256 price,
      uint16 set,
      uint8 number,
      bool enabled
    ) {

    Listing storage listing = listings[cardListings[_set][_number][index]];
    return (
      listing.listingId,
      listing.id,
      listing.seller,
      listing.price,
      listing.set,
      listing.number,
      listing.enabled);
  }

  function getListingBySeller(address _seller, uint256 index) external view returns (
      uint256 listingId,
      uint256 id,
      address seller,
      uint256 price,
      uint16 set,
      uint8 number,
      bool enabled
    ) {

    Listing storage listing = listings[sellerListings[_seller][index]];
    return (
      listing.listingId,
      listing.id,
      listing.seller,
      listing.price,
      listing.set,
      listing.number,
      listing.enabled);
  }

  function submitListing(uint256 _id, uint256 price) external {
    nft.transferFrom(msg.sender, address(this), _id);
    (uint16 cardSet, uint8 _number) = nft.metadataOf(_id);
    listingCounter++;
    listings[listingCounter] = Listing(listingCounter, _id, msg.sender, price,  cardSet, _number, true);
    cardListings[cardSet][_number].push(listingCounter);
    sellerListings[msg.sender].push(listingCounter);
    emit NewListing(listingCounter, _id, msg.sender, price, cardSet, _number);
  }

  function buyListing(uint256 listingId) external {
    Listing storage listing = listings[listingId];
    require(listing.enabled, 'Listing disabled');
    token.transferFrom(msg.sender, listing.seller, listing.price);
    nft.transferFrom(address(this), msg.sender, listing.id);
    listing.enabled = false;
    emit Sale(listingId, listing.id, msg.sender, listing.seller);
  }

  function cancelListing(uint256 listingId) external {
    Listing storage listing = listings[listingId];
    require(listing.seller == msg.sender, 'Not owner');
    require(listing.enabled, 'Listing disabled');
    nft.transferFrom(address(this), msg.sender, listing.id);
    listing.enabled = false;
    emit ListingCancelled(listingId, listing.id, msg.sender);
  }
  
  function changeListingPrice(uint256 listingId, uint256 newPrice) external {
    Listing storage listing = listings[listingId];
    require(listing.seller == msg.sender, 'Not owner');
    require(listing.enabled, 'Listing disabled');
    listing.price = newPrice;
    emit ListingPriceChanged(listing.listingId, listing.id, listing.seller, newPrice);
  }

  fallback () external {
    revert();
  }
}