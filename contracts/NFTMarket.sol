// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol"; // needed count the nfts
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // add whenever a contract talks to another
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    uint256 listingPrice = 0.07 ether; //NOT ETHEREUM this is actually whatever network you are deploying too

    constructor() {
        owner = payable(msg.sender);
    }

    // What is required in each MarketItem
    // Add derivitives of MarketItem for the future
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // A way to keep up with each item created in the marketplace
    mapping(uint256 => MarketItem) private idToMarketItem;

    // A way to keep up with Items add by each seller
    // Implement mapping
    // mapping(address => mapping(uint256 => MarketItem)) private idToMarketItem;

    // Item Sucessfully Created
    // Listen to events on etherscan in a front end application
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /* Places an item for sale on the marketplace */
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        // Prevents reentry attack
        require(price > 0, "Price must be at least 1 wei"); // Minimum listing price
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        ); // Require isting price = transaction price

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        // Sets the item for sale and adds to Market Item
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            // There is no currently no OWNER since the seller is listing the item
            payable(address(0)),
            price,
            false
        );

        // Transfer Ownership from Owner to the next Buyer
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // Send the message to block explorer
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

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );

        // transfer the value of the transaction to the sellers address
        idToMarketItem[itemId].seller.transfer(msg.value);

        // transfer the ownership of the NFT to the buyer address
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        // set the owner on our end to the buyer
        idToMarketItem[itemId].owner = payable(msg.sender);

        // set the item to sold
        idToMarketItem[itemId].sold = true;

        // increment items sold
        _itemsSold.increment();

        // pay the seller address
        payable(owner).transfer(listingPrice);
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        // Loops through all items to see which are unsold
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // use for special access
    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
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

    /* Returns only items a user has created */
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
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
}
