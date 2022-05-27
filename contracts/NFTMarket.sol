//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // prevents re-entrancy attacks

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds; // total number of items ever created on the marketplace
    Counters.Counter private _itemsSold; // total number of items sold on the marketplace

    // the "owner" of the smart contract will be receiving commissions by sale
    address payable owner; // owner of the smart contract

    // listingPrice is the price the creator have to pay to put their NFT on this marketplace
    //TODO: Code a function, so that you can change the listingPrice by FrontEnd (AdminDashboard)
    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    // struct is similiar to arrays, they list multiple objects
    // struct is like a row in a database
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // access the struct like you would with an array
    // e.g. access the MarketItem with ID 4 = idMarketItem[4]
    // access values of the MarketItem struct above by passing an integer ID
    mapping(uint256 => MarketItem) private idMarketItem;

    // define an event (is similiar to console.log)
    // whenever a NFT is sold, we want to log the message with "emit MarketItemCreated()"
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    /// @notice function to get listing price
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /// @notice function to set listing price
    function setListingPrice(uint256 _listingPrice) public returns (uint256) {
        // check if the user has the permission to change the listingPrice
        // by checking if the user is the owner of the nft
        if (address(this) == msg.sender) {
            listingPrice = _listingPrice;
        }
        return listingPrice;
    }

    /// @notice function to create market item
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be above zero");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        _itemIds.increment(); // add 1 to the total number of items ever created on the marketplace
        uint256 itemId = _itemIds.current();

        // call struct MarketItem as a function
        idMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender), // address of the seller putting the nft up for sale
            payable(address(0)), // no owner yet (set owner to empty address)
            price,
            false
        );

        // transfer ownership of the nft to the contract itself
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // print/log the defined event MarketItemCreated
        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    /// @notice function to create a sale
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idMarketItem[itemId].price;
        uint256 tokenId = idMarketItem[itemId].tokenId;

        require(
            msg.value == price,
            "Please submit the asking price in order to complete purchase"
        );

        //TODO: Add a require() which checks, if the owner is not the buyer

        // pay the seller the amount
        idMarketItem[itemId].seller.transfer(msg.value);

        // transfer ownership of the nft from the contract itself to the buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        idMarketItem[itemId].owner = payable(msg.sender); // mark buyer as new owner
        idMarketItem[itemId].sold = true; // mark that it has been sold
        _itemsSold.increment(); // increase the total number of Items sold by 1
        payable(owner).transfer(listingPrice); // pay owner of contract the listing price
    }

    /// @notice fetch list of items unsold on the marketplace
    function fetchUnsoldMarketItems()
        public
        view
        returns (MarketItem[] memory)
    {
        uint256 totalItemCount = _itemIds.current(); // total number of items ever created
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current(); // total number of items that are unsold = total items ever created - total items ever sold
        uint256 currentIndex = 0;

        // create a tempory array of all market items
        // because of "memory" it is temporary
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        // loop through all items ever created
        for (uint256 i = 0; i < totalItemCount; i++) {
            // get only unsold items
            // check if the item has not been sold by checking if the owner field is empty
            if (idMarketItem[i + 1].owner == address(0)) {
                // this item has never been sold
                uint256 currentId = idMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items; // return array of all unsold items
    }

    /// @notice fetch list of NFTs owned/bought by this user
    function fetchMyOwnedMarketItems()
        public
        view
        returns (MarketItem[] memory)
    {
        uint256 totalItemCount = _itemIds.current(); // total number of items ever created

        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        // loop through all items ever created
        for (uint256 i = 0; i < totalItemCount; i++) {
            // get only the items that this user has bought/is the owner
            if (idMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1; // total length
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = idMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /// @notice fetch list of NFTs created by this user
    function fetchMyCreatedNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current(); // total number of items ever created

        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        // loop through all items ever created
        for (uint256 i = 0; i < totalItemCount; i++) {
            // get only the items that this user has created
            if (idMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1; // total length
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = idMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
