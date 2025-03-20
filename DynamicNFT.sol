// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DynamicNFT {
    // Struct to store NFT attributes
    struct NFT {
        uint256 id;
        uint256 attribute;
        uint256 lastUpdated;
    }

    // Mapping to store NFTs owned by each address
    mapping(address => NFT[]) public nfts;

    // Event to notify when an NFT attribute changes
    event NFTUpdated(address indexed owner, uint256 id, uint256 newAttribute);

    // Function to create a new NFT (no constructor, no input)
    function createNFT() public {
        uint256 newId = nfts[msg.sender].length + 1; // Unique ID based on length
        uint256 randomAttribute = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, newId))) % 100; // Random attribute
        uint256 currentTime = block.timestamp;

        nfts[msg.sender].push(NFT(newId, randomAttribute, currentTime));
    }

    // Function to update the attribute of an NFT (changes over time)
    function updateNFTAttribute(uint256 nftId) public {
        // Ensure the sender owns the NFT
        require(nftId > 0 && nftId <= nfts[msg.sender].length, "NFT does not exist");

        NFT storage userNFT = nfts[msg.sender][nftId - 1];

        // Update the attribute only if the NFT has not been updated in the last 24 hours
        require(block.timestamp >= userNFT.lastUpdated + 1 days, "Attribute can only be updated once a day");

        // Change the attribute based on the current time
        uint256 newAttribute = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nftId))) % 100;

        userNFT.attribute = newAttribute;
        userNFT.lastUpdated = block.timestamp;

        emit NFTUpdated(msg.sender, nftId, newAttribute);
    }

    // Function to get details of a specific NFT owned by a user
    function getNFT(address owner, uint256 nftId) public view returns (uint256 id, uint256 attribute, uint256 lastUpdated) {
        require(nftId > 0 && nftId <= nfts[owner].length, "NFT does not exist");
        
        NFT memory userNFT = nfts[owner][nftId - 1];
        return (userNFT.id, userNFT.attribute, userNFT.lastUpdated);
    }
}
