const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarket", function () {
  it("Should create and execute market sales", async function () {
    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed(); // deploy the NFTMarket contract
    const marketAddress = market.address; // blockchain address of the NFTMarket contract

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed(); // deploy the NFT contract
    const nftContractAddress = nft.address; // blockchain address of the nft contract

    // get the listing price
    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();

    // set an auction price
    const auctionPrice = ethers.utils.parseUnits("100", "ether");

    // create 2 test tokens
    await nft.createToken("https://www.mytokenlocation1.com");
    await nft.createToken("https://www.mytokenlocation2.com");

    // create 2 test nfts
    await market.createMarketItem(nftContractAddress, 1, auctionPrice, {
      value: listingPrice,
    });
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, {
      value: listingPrice,
    });

    const [_, buyerAddress] = await ethers.getSigners();

    // create test sale
    await market
      .connect(buyerAddress)
      .createMarketSale(nftContractAddress, 1, { value: auctionPrice });

    // fetch unsold market items
    let items = await market.fetchUnsoldMarketItems();

    items = await Promise.all(
      items.map(async (i) => {
        const tokenURI = await nft.tokenURI(i.tokenId);

        let item = {
          price: i.price.toString(),
          tokenId: i.tokenId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenURI,
        };
        return item;
      })
    );

    console.log("all unsold items: ", items);
  });
});
