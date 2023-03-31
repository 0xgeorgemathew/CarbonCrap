// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Carbon Credit NFT
/// @author Your Name
/// @notice A contract for minting, marking as used, and verifying unique IDs for Carbon Credit NFTs
contract CarbonCreditNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;

    struct CarbonCredit {
        string metadata;
        bool isUsed;
    }

    mapping(uint256 => CarbonCredit) public carbonCredits;
    mapping(bytes32 => bool) public uniqueIdExists;

    event CarbonCreditMarkedAsUsed(uint256 indexed tokenId);

    /// @notice Initializes the Carbon Credit NFT contract
    constructor() ERC721("CarbonCreditNFT", "CCNFT") {}

    /// @notice Mints a new Carbon Credit NFT with the provided hashed unique ID and metadata
    /// @dev The unique ID must not be in use already
    /// @param hashedUniqueId The hashed unique ID for the new Carbon Credit NFT
    /// @param metadata The metadata for the new Carbon Credit NFT
    function mintCarbonCreditNFT(
        bytes32 hashedUniqueId,
        string memory metadata
    ) public {
        require(
            !uniqueIdExists[hashedUniqueId],
            "Carbon Credit NFT: This unique ID is already used."
        );

        uint256 newTokenId = _tokenIdTracker.current();

        carbonCredits[newTokenId] = CarbonCredit(metadata, false);
        uniqueIdExists[hashedUniqueId] = true;

        _mint(msg.sender, newTokenId);
        _tokenIdTracker.increment();
    }

    /// @notice Marks a Carbon Credit NFT as used
    /// @dev The caller must be the owner of the NFT
    /// @param tokenId The ID of the Carbon Credit NFT to mark as used
    function markAsUsed(uint256 tokenId) public {
        require(
            ownerOf(tokenId) == msg.sender,
            "Carbon Credit NFT: You are not the owner of this NFT."
        );

        carbonCredits[tokenId].isUsed = true;

        emit CarbonCreditMarkedAsUsed(tokenId);
    }

    /// @notice Verifies if a hashed unique ID matches the expected hash for a given token ID
    /// @dev The unique ID must exist
    /// @param hashedUniqueId The hashed unique ID to verify
    /// @param tokenId The token ID to check against
    /// @return True if the hashed unique ID matches the expected hash for the given token ID
    function verifyUniqueId(
        bytes32 hashedUniqueId,
        uint256 tokenId
    ) public view returns (bool) {
        require(
            uniqueIdExists[hashedUniqueId],
            "Carbon Credit NFT: This unique ID does not exist."
        );

        uint256 tokenIndex = tokenId - 1;
        bytes32 calculatedHash = keccak256(abi.encodePacked(tokenIndex));

        return calculatedHash == hashedUniqueId;
    }
}
