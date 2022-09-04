//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

// error Audoxo__TokenUriMustNotBeEmpty();
// error Audoxo__AlreadyMinted();
// error Audoxo__NftNotMinted();

// contract Audoxo is ERC721URIStorage {
//   //total Tokens
//   string[] public audoxos;

//   //total Listings
//   uint256[] public totalListings;

//   //owner to totalListings
//   mapping(address => uint256[]) public totalListingsOfOwner;

//   //tokenId to Listing
//   mapping(uint256 => Listing) public listing;

//   //tokenUri to already minted
//   mapping(string => bool) _audoxos;

//   struct Listing {
//     address seller;
//     uint256 price;
//     string _tokenUri;
//   }

//   constructor() ERC721("Audoxo", "ADXO") {}

//   function mintNft(string memory _tokenURI) public payable {
//     if (bytes(_tokenURI).length <= 0) {
//       revert Audoxo__TokenUriMustNotBeEmpty();
//     }
//     if (!_audoxos[_tokenURI]) {
//       revert Audoxo__AlreadyMinted();
//     }

//     audoxos.push(_tokenURI);
//     uint256 tokenId = audoxos.length - 1;

//     _mint(msg.sender, tokenId);

//     _audoxos[_tokenURI] = true;

//     _setTokenURI(tokenId, _tokenURI);
//   }

//   function listItem(uint256 tokenId, uint256 price)
//     external
//     notListed(tokenId, msg.sender)
//     isOwner(tokenId, msg.sender)
//   {
//     if (price <= 0) {
//       revert NftMarketplace__PriceMustBeAboveZero();
//     }

//     IERC721 nft = IERC721(nftAddress);
//     if (nft.getApproved(tokenId) != address(this)) {
//       revert NftMarketplace__NotApprovedForMarketlace();
//     }

//     s_listings[nftAddress][tokenId] = Listing(price, msg.sender);

//     emit itemListed(msg.sender, nftAddress, tokenId, price);
//   }

//   // /* allows someone to resell a token they have purchased */
//   // function resellToken(uint256 tokenId, uint256 price) public payable {
//   //   require(
//   //     idToMarketItem[tokenId].owner == msg.sender,
//   //     "Only item owner can perform this operation"
//   //   );
//   //   require(idToMarketItem[tokenId].seller != address(0), "Already Listed!");
//   //   require(msg.value == listingPrice, "Price must be equal to listing price");

//   //   idToMarketItem[tokenId].sold = false;
//   //   idToMarketItem[tokenId].price = price;
//   //   idToMarketItem[tokenId].seller = payable(msg.sender);
//   //   idToMarketItem[tokenId].owner = payable(address(this));
//   //   _itemsSold.decrement();

//   //   _transfer(msg.sender, address(this), tokenId);
//   // }
// }
