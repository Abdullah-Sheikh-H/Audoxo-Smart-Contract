// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error Audoxo__TokenUriMustNotBeEmpty();
error Audoxo__AlreadyMinted();
error PublicMintIsPaused();

contract AudoxoMarketplace is ERC721URIStorage, ReentrancyGuard, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  Counters.Counter private _listItemId;
  Counters.Counter private _itemsSold;

  uint256 listingPrice = 0.025 ether;
  uint256 listingProceeds;
  address[] public vipAddresses;
  uint256 mintLimit;
  string revealUri =
    "ipfs://bafybeif5gb5rcumc44uheaniihqjzdv2rqjxd2hlkmpowowtvgujfe7tui/revealMetadata.json";
  bool publicMint;
  bool paused;
  bool mintPaused;
  bool revealed;

  mapping(uint256 => MarketItem) private idToMarketItem;

  // sellers to Proceeds
  mapping(address => uint256) private sellerProceeds;

  //tokenUri to already minted
  mapping(string => bool) _audoxos;

  //address to isVip
  mapping(address => bool) public isVip;

  //address to total mintings left
  mapping(address => uint256) public mintingLeft;

  struct MarketItem {
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

  event MarketItemCreated(
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold
  );

  modifier isPaused() {
    require(!paused, "Contract is Paused");
    _;
  }

  modifier isMintPaused() {
    require(!mintPaused, "Minting is Paused");
    _;
  }

  constructor(
    uint256 _mintlimit,
    bool _paused,
    bool _publicMint,
    bool _mintPaused,
    bool _revealed
  ) ERC721("Audoxo", "ADXO") {
    mintLimit = _mintlimit;
    paused = _paused;
    publicMint = _publicMint;
    isVip[msg.sender] = true;
    mintPaused = _mintPaused;
    revealed = _revealed;
  }

  /* Updates the listing price of the contract */
  function updateListingPrice(uint256 _listingPrice) public payable onlyOwner {
    listingPrice = _listingPrice;
  }

  /* Mints a token in the marketplace */
  function mintToken(string memory _tokenURI)
    public
    payable
    isPaused
    isMintPaused
    returns (uint256)
  {
    if (bytes(_tokenURI).length <= 0) {
      revert Audoxo__TokenUriMustNotBeEmpty();
    }
    if (_audoxos[_tokenURI]) {
      revert Audoxo__AlreadyMinted();
    }

    if (!isVip[msg.sender]) {
      if (publicMint) {
        require(
          !(mintingLeft[msg.sender] >= mintLimit),
          "Minting limit exeeded!"
        );
        mintingLeft[msg.sender] += 1;
      } else {
        revert PublicMintIsPaused();
      }
    }

    _audoxos[_tokenURI] = true;

    _tokenIds.increment();
    uint256 newTokenId = _tokenIds.current();

    _mint(msg.sender, newTokenId);
    _setTokenURI(newTokenId, _tokenURI);

    idToMarketItem[newTokenId] = MarketItem(
      newTokenId,
      payable(address(0)),
      payable(msg.sender),
      0,
      false
    );

    emit MarketItemCreated(newTokenId, address(0), msg.sender, 0, false);

    return newTokenId;
  }

  function createMarketItem(uint256 tokenId, uint256 price)
    public
    payable
    isPaused
  {
    require(price > 0, "Price must be at least 1 wei");
    require(msg.value == listingPrice, "Price must be equal to listing price");
    require(idToMarketItem[tokenId].seller == address(0), "Already Listed!");
    require(
      idToMarketItem[tokenId].owner == msg.sender,
      "Only owner can List Item!"
    );

    _listItemId.increment();

    idToMarketItem[tokenId].sold = false;
    idToMarketItem[tokenId].price = price;
    idToMarketItem[tokenId].seller = payable(msg.sender);
    idToMarketItem[tokenId].owner = payable(address(this));

    _transfer(msg.sender, address(this), tokenId);
    //listing price send to contract
    listingProceeds += 0.025 ether;
    emit MarketItemCreated(tokenId, msg.sender, address(this), price, false);
  }

  /* Creates the sale of a marketplace item */
  /* Transfers ownership of the item, as well as funds between parties */
  function createMarketSale(uint256 tokenId) public payable isPaused {
    uint256 price = idToMarketItem[tokenId].price;
    address seller = idToMarketItem[tokenId].seller;
    require(seller != msg.sender, "Owner cant buy his Own Nft");
    require(
      msg.value >= price,
      "Please submit the asking price in order to complete the purchase"
    );
    idToMarketItem[tokenId].owner = payable(msg.sender);
    idToMarketItem[tokenId].sold = true;
    idToMarketItem[tokenId].seller = payable(address(0));
    _itemsSold.increment();
    _transfer(address(this), msg.sender, tokenId);
    sellerProceeds[seller] += msg.value;

    emit MarketItemCreated(tokenId, address(0), msg.sender, price, true);
  }

  function withdrawProceeds() public payable isPaused nonReentrant {
    require(
      sellerProceeds[msg.sender] > 0,
      "Can't withdraw, balance is empty!"
    );
    uint256 totalProceeds = sellerProceeds[msg.sender];
    sellerProceeds[msg.sender] = 0;
    payable(msg.sender).transfer(totalProceeds);
  }

  /* Returns all unsold market items */
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint256 itemCount = _listItemId.current();
    uint256 unsoldItemCount = _listItemId.current() - _itemsSold.current();
    uint256 currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint256 i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(this)) {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns only items that a user has purchased */
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint256 totalItemCount = _tokenIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns only items a user has listed */
  function fetchItemsListed() public view returns (MarketItem[] memory) {
    uint256 totalItemCount = _listItemId.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    if (revealed) {
      return super.tokenURI(tokenId);
    } else {
      return revealUri;
    }
  }

  function togglePublicMinting() public onlyOwner {
    publicMint = !publicMint;
  }

  function togglePause() public onlyOwner {
    paused = !paused;
  }

  function toggleReveal() public onlyOwner {
    revealed = !revealed;
  }

  function toggleMintPause() public onlyOwner {
    mintPaused = !mintPaused;
  }

  function setVip(address toVip) public onlyOwner {
    require(!isVip[toVip], "Address is already vip");
    isVip[toVip] = true;
    vipAddresses.push(toVip);
  }

  function removeVip(address toVip) public onlyOwner {
    require(isVip[toVip], "Address is already not a vip");
    isVip[toVip] = false;
    uint256 vipLength = vipAddresses.length;
    for (uint256 i = 0; i >= vipLength; i++) {
      if (vipAddresses[i] == toVip) {
        delete vipAddresses[i];
      }
    }
  }

  function updateMintLimit(uint256 newLimit) public onlyOwner {
    mintLimit = newLimit;
  }

  function updateUserLimit(address toReset, uint256 listingAmt)
    public
    onlyOwner
  {
    require(!isVip[toReset], "Address is Vip");
    require(mintingLeft[toReset] != 0, "Already at min limit");
    mintingLeft[toReset] -= listingAmt;
  }

  function withdrawListingPrice() public payable onlyOwner {
    require(listingProceeds != 0, "cant withdraw 0 eth");
    uint256 price = listingProceeds;
    listingProceeds = 0;
    payable(msg.sender).transfer(price);
  }

  function getMintPauseStatus() public view returns (bool) {
    return mintPaused;
  }

  function getRevealState() public view returns (bool) {
    return revealed;
  }

  function getPauseState() public view returns (bool) {
    return paused;
  }

  function getPublicMintState() public view returns (bool) {
    return publicMint;
  }

  function getMintLimit() public view returns (uint256) {
    return mintLimit;
  }

  function getVipAddresses() public view returns (address[] memory) {
    return vipAddresses;
  }

  /* Returns the listing price of the contract */
  function getListingPrice() public view returns (uint256) {
    return listingPrice;
  }

  /* Returns the proceeds of the seller */
  function getProceeds() public view returns (uint256) {
    return sellerProceeds[msg.sender];
  }

  //get contract balance
  function getContractBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function getListingProceeds() public view onlyOwner returns (uint256) {
    return listingProceeds;
  }

  function getMintingsLeft() public view returns (uint256) {
    uint256 left = mintLimit - mintingLeft[msg.sender];
    return left;
  }
}
