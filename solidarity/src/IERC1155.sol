// Compatible with OpenZeppelin Contracts ^5.0.0
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC1155Errors} from "../lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";
import {ERC1155Utils} from "../lib/openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Utils.sol";


contract ProjectToken is ERC1155, Ownable {
        // Stockage interne des soldes : _balances[id][adresse] = quantité
    mapping(uint256 id => mapping(address account => uint256)) private _balances;

    // URI de base pour les métadonnées de tous les tokens ERC1155
    string private _uri;

    // Le constructeur définit le propriétaire initial et appelle le constructeur ERC1155
    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {}

    // Fonction de mint : création de nouveaux tokens d'ID donné pour une adresse
    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    // Mint en masse : permet de créer plusieurs IDs et quantités de tokens en une seule transaction
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // Consulte le solde pour un token précis (id) et une adresse
    function balanceOf(address account, uint256 id) public view virtual override returns(uint256)
    {
        return _balances[id][account];
    }

    // Consulte les soldes pour plusieurs adresses et plusieurs IDs en une seule fois
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view virtual override returns (uint256[] memory)
    {
        // Vérifie que la longueur des tableaux est identique
        if (accounts.length != ids.length) {
            revert ERC1155InvalidArrayLength(ids.length, accounts.length);
        }

        uint256[] memory batchBalances = new uint256[](accounts.length);
        // Boucle pour récupérer chaque solde individuellement
        for (uint256 i = 0; i < accounts.length; ++i){
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    // Retourne l'URI utilisée pour les métadonnées
    function uri(uint256 id) public view virtual override returns (string memory) {
        return _uri;
    }

    // Met à jour l'URI interne
    function _setURI(string memory newuri) internal virtual override {
        _uri = newuri;
    }

    // Met à jour les soldes lors d'un transfert simple ou en batch
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal virtual override
    {
        // Vérifie que la taille des IDs et des valeurs correspond
        if (ids.length != values.length) {
            revert ERC1155InvalidArrayLength(ids.length, values.length);
        }

        address operator = _msgSender();

        // Pour chaque token transféré, on débite l'expéditeur et on crédite le destinataire
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];

            if (from != address(0)) {
                uint256 fromBalance = _balances[id][from];
                if (fromBalance < value) {
                    revert ERC1155InsufficientBalance(from, fromBalance, value, id);
                }
                // Mise à jour du solde de l'expéditeur
                unchecked {
                    // Overflow not possible: value <= fromBalance
                    _balances[id][from] = fromBalance - value;
                }
            }

            if (to != address(0)) {
                // Mise à jour du solde du destinataire
                _balances[id][to] += value;
            }
        }
        // Émet un événement de transfert unique ou multiple
        if (ids.length == 1) {
            uint256 id = ids[0];
            uint256 value = values[0];
            emit TransferSingle(operator, from, to, id, value);
        } else {
            emit TransferBatch(operator, from, to, ids, values);
        }
    }

    // Vérifie la réception des tokens (conformité ERC1155) et applique la logique de _update
    function _updateWithAcceptanceCheck(address from, address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal virtual override
    {
        _update(from, to, ids, values);
        if (to != address(0)) {
            address operator = _msgSender();
            if (ids.length == 1) {
                uint256 id = ids[0];
                uint256 value = values[0];
                // Appel des fonctions de vérification pour garantir que le destinataire sait gérer des ERC1155
                ERC1155Utils.checkOnERC1155Received(operator, from, to, id, value, data);
            } else {
                ERC1155Utils.checkOnERC1155BatchReceived(operator, from, to, ids, values, data);
            }
        }
    }
}
