// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//ERC 721
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    //update the ERC721("Token Name", "Token Short Name")
    constructor(address marketplaceAddress) ERC721("Let's Link", "MARCI") {
        contractAddress = marketplaceAddress;
    }

    //for minting new tokens
    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId; // important for listing a token
    }
}
