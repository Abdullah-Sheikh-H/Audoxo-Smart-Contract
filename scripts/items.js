const { ethers } = require("hardhat")

const main = async () => {
  const nftMarketplace = await ethers.getContract("AudoxoMarketplace")

  // await nftMarketplace.deployed()

  // let listingPrice = await nftMarketplace.getListingPrice()
  // listingPrice = listingPrice.toString()

  const acc = await ethers.getSigners()
  const account = acc[1]

  // console.log(account)

  // await nftMarketplace.setVip("0x3b68056735085Ae19bAf5997953b225433e01a46")

  // await nftMarketplace.togglePublicMinting()

  const nft = await nftMarketplace.connect(account)
  const data = await nft.getMintingsLeft()
  console.log(data)

  // await nftMarketplace.updateUserLimit(
  //   "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
  //   1
  // )

  // await nft.mintToken("ass25hj")
  // await nftMarketplace.togglePublicMinting()
  // await nftMarketplace.toggleReveal()

  // const auctionPrice = ethers.utils.parseUnits("1", "ether")

  // /* create two tokens */
  // await nftMarketplace.createToken(
  //   "https://www.mytokenlocation.com",
  //   auctionPrice,
  //   { value: listingPrice }
  // )
  // await nftMarketplace.createToken(
  //   "https://www.mytokenlocation2.com",
  //   auctionPrice,
  //   { value: listingPrice }
  // )

  // const [_, buyerAddress] = await ethers.getSigners()
  // // const lt = await nftMarketplace.getListingPrice()
  // const ltp = ethers.utils.parseEther("0.025")
  // // const ltpr = lt.toString()

  // /* query for and return the unsold items */
  // const price = ethers.utils.parseEther("1")
  // // const pricer = price.toString()
  // await nftMarketplace.createMarketItem(2, price, {
  //   value: listingPrice,
  // })

  // const uri = await nftMarketplace.tokenURI(2)
  // console.log(uri)
  // items = await Promise.all(
  //   items.map(async (i) => {
  //     const tokenUri = await nftMarketplace.tokenURI(i.tokenId)
  //     let item = {
  //       price: i.price.toString(),
  //       tokenId: i.tokenId.toString(),
  //       seller: i.seller,
  //       owner: i.owner,
  //       tokenUri,
  //     }
  //     return item
  //   })
  // )
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
