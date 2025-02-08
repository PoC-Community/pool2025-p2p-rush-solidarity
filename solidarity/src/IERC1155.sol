// Compatible with OpenZeppelin Contracts ^5.0.0
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ProjectToken is ERC1155, Ownable {
    // ID des tokens ERC1155
    uint256 public constant TOKEN_ID = 1; // Token fongible
    uint256 public constant NFT_ID = 2;   // NFT unique

    // Métadonnées du token
    string public name;
    string public symbol;
    uint256 public maxSupply;

    event ProjectNFTMinted(address indexed owner, uint256 tokenId);

    constructor(
        address initialOwner,
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply
    ) ERC1155("") Ownable(initialOwner) {
        name = _name;
        symbol = _symbol;
        maxSupply = _maxSupply;

        // Minter 100% des tokens au Core contract
        _mint(initialOwner, TOKEN_ID, maxSupply, "");

        // Minter le NFT unique pour le propriétaire
        // _mint(initialOwner, NFT_ID, 1, "");
        emit ProjectNFTMinted(initialOwner, NFT_ID);
    }

    /**
     * @dev Mint en batch des tokens ERC1155 pour chaque contributeur.
     * @param contributors Liste des adresses des contributeurs.
     * @param amounts Montants des tokens à minter pour chaque contributeur.
     */
    function mintTokensForContributors(address[] memory contributors, uint256[] memory amounts) external onlyOwner {
        require(contributors.length == amounts.length, "Arrays must have same length");

        for (uint256 i = 0; i < contributors.length; i++) {
            _safeTransferFrom(owner(), contributors[i], TOKEN_ID, amounts[i], "");
        }
    }

    /**
     * @dev Minte un NFT unique pour le propriétaire du projet (optionnel).
     * Peut être appelé si le projet décide de donner un NFT en plus.
     */
    function mintProjectNFT() external onlyOwner {
        require(balanceOf(owner(), NFT_ID) == 0, "NFT already minted");
        _mint(owner(), NFT_ID, 1, "");
        emit ProjectNFTMinted(owner(), NFT_ID);
    }
}
