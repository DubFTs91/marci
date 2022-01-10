
/* Test */
describe("NFTMarket", function () {
  it("Should create and execute market sales", async function () {
    /* deploy the marketplace */
    const Market = await ethers.getContractFactory("NFTMarket")
    const market = await Market.deploy()
    await market.deployed()
    const marketAddress = market.address

    /* deploy the NFT contract */
    const NFT = await ethers.getContractFactory("NFT")
    const nft = await NFT.deploy(marketAddress)
    await nft.deployed()
    const nftContractAddress = nft.address

    let listingPrice = await market.getListingPrice()


    listingPrice = listingPrice.toString()

    const auctionPrice = ethers.utils.parseUnits('10', 'ether')

    /* create two tokens */
    await nft.createToken("https://www.testtoken1.com")
    await nft.createToken("https://www.testtoken2.com")

    /* put both tokens for sale */
    await market.createMarketItem(nftContractAddress, 1, auctionPrice, { value: listingPrice })
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, { value: listingPrice })

    /* get a test account */
    /*const [_, buyerAddress, thirdAddress, fourthAddress] = await ethers.getSigners()*/
    const [_, buyerAddress] = await ethers.getSigners()

    /* execute sale of token to another user */
    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, { value: auctionPrice })

    /* query for and return the unsold items */
    items = await market.fetchMarketItems()

    // promise.all guarentees async for all items
    // price in WEI = ETH 10 ** 18
    items = await Promise.all(items.map(async i => {
      const tokenUri = await nft.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return item
    }))
    console.log('items: ', items)
  })
})