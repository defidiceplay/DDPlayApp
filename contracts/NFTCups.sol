// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Chips.sol";


contract NFTCups is ERC721 {


// Restrictions
    address public owner_address = msg.sender;
    modifier Owner() {
        require(
            msg.sender == owner_address,
            "This function is restricted to the contract's owner"
        );
        _;
    }

    address public boardplay_address;
    function set_boardplay_address(address new_boardplay_address) public Owner { boardplay_address = new_boardplay_address; }
    modifier Boardplay() {
        require(
            msg.sender == boardplay_address,
            "This function is restricted to the Board Play Contract"
        );
        _;
    }

    address public pvp_address;
    function set_pvp_address(address new_pvp_address) public Owner { pvp_address = new_pvp_address; }
    modifier PVP() {
        require(
            msg.sender == pvp_address,
            "This function is restricted to the PVP Contract"
        );
        _;
    }



// Chips
    address public chips_addr = 0x4D2744a7070F07154EDc0097F8A64265389136E2;
    Chips acceptedChips;



// Constructor
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
            acceptedChips = Chips(chips_addr);
    }



// NFT Information
    struct Cups {
        uint8 rare; //0-255
        uint256 remainingMatch;
        uint8 diceInMatch;
        uint16 wastage;
    }

    uint256 nextId = 0;
    mapping( uint256 => Cups) private _tokenDetails;

    uint256 maxNumberCups = 10;
    function setMaxNumberCups(uint256 newMaxNumberCups) public Owner {
        maxNumberCups = newMaxNumberCups;
    }

    uint256 maxTotalCups = 100;
    function setTotalCups(uint256 newTotalCups) public Owner {
        maxTotalCups = newTotalCups;
    }

// Marketplace
    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) private _tokenMarket;

    struct ListingAux {
        uint256 tokenId;
        address seller;
        uint256 price;
    }



// Mint Price BNB
    uint256 priceBNB = 8 * 10 ** 16; // 0.08 BNB -> to 0.1 BNB when NFT's presale finalice
    function setPriceMintBNB(uint256 newPriceMintBNB) public Owner { priceBNB = newPriceMintBNB; }

// Mint In BNB
    uint256 mintInBNB = 1; // 1 -> In BNB, 0 -> In CLAP
    function setMintInBNB(uint256 newMintInBNB) public Owner { mintInBNB = newMintInBNB; }



// Gets
    function getNumberMintedCups() public view returns (uint256) {
        return nextId;
    }


    function getTokenDetails(uint256 tokenId) public view returns (Cups memory)  { return _tokenDetails[tokenId]; }
    
    
    function getAllTokensForUser(address user) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(user);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint[] memory result = new uint256[](tokenCount);
            uint256 totalCups = nextId;
            uint256 resultIndex = 0;
            uint256 i;
            for (i = 0; i < totalCups; i++) {
                if (_exists(i) && ownerOf(i) == user && _tokenDetails[i].wastage > 0) {
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            uint[] memory result2 = new uint256[](resultIndex);
            uint256 j;
            for (j = 0; j < resultIndex; j++) {
                result2[j] = result[j];
            }
            return result2;
        }
    }


    function getAllTokensWasteForUser(address user) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(user);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint[] memory result = new uint256[](tokenCount);
            uint256 totalCups = nextId;
            uint256 resultIndex = 0;
            uint256 i;
            for (i = 0; i < totalCups; i++) {
                if (_exists(i) && ownerOf(i) == user && _tokenDetails[i].wastage == 0) {
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            uint[] memory result2 = new uint256[](resultIndex);
            uint256 j;
            for (j = 0; j < resultIndex; j++) {
                result2[j] = result[j];
            }
            return result2;
        }
    }


    function getAllItemsMarket() public view returns (ListingAux [] memory) {
        uint256 totalCups = nextId;
        ListingAux [] memory result = new ListingAux [](totalCups);
        uint256 i;
        for (i = 0; i < totalCups; i++) {
            if (_tokenMarket[i].seller != address(0)) {
                result[i] = ListingAux(i, _tokenMarket[i].seller, _tokenMarket[i].price);
            }
        }
        return result;
    }


    function getNumberItems(address user) public view returns (uint256) {
        uint256 totalCups = nextId;
        uint256 numCups = balanceOf(user);
        uint256 i;
        for (i = 0; i < totalCups; i++) {
            if (_tokenMarket[i].seller == user) numCups += 1;
        }
        return numCups;
    }


    function getCapacity(address user) public view returns (uint256) {
        uint256 tokenCount = balanceOf(user);
        if (tokenCount == 0) {
            return 0;
        } else {
            uint256 result = 0;
            uint256 totalCups = nextId;
            uint256 i;
            for (i = 0; i < totalCups; i++) {
                if (_exists(i) && ownerOf(i) == user && _tokenDetails[i].wastage > 0) {
                   result += _tokenDetails[i].diceInMatch;
                }
            }
            return result;
        }
    }



// Sets
    function mint() external payable {
        require(maxTotalCups > nextId, "it is not allowed to mine more cups!");
        require(maxNumberCups > getNumberItems(msg.sender), "You can't mint more cups!");

        if (mintInBNB == 1) {
            require(msg.value == priceBNB, "Failed to send BNB");
            payable(acceptedChips.get_addressForPool()).transfer(priceBNB);
        } else {
            acceptedChips.mint(msg.sender);
        }

        uint8 rare = acceptedChips.mintCup();
        _tokenDetails[nextId] = Cups(rare, 0, 0, 100*uint16(rare));

        _safeMint(msg.sender, nextId);
        nextId++;
    }


    function startMatch(uint256 tokenId, uint8 typematch, uint8 numDices, uint8 formpay) external payable {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of the token");
        require(_tokenDetails[tokenId].remainingMatch == 0, "This Cup have active match");
        require(_tokenDetails[tokenId].wastage >= typematch*10*numDices, "You do not have sufficient waste!");
        require(numDices > 0 && numDices <= _tokenDetails[tokenId].rare, "Number of dices equal or less than Cup rarity");

        acceptedChips.startMatch(msg.sender, typematch, numDices, formpay);
        if (typematch == 1) _tokenDetails[tokenId].remainingMatch = 10;
        else if (typematch == 2) _tokenDetails[tokenId].remainingMatch = 20;
        else _tokenDetails[tokenId].remainingMatch = 30;
        _tokenDetails[tokenId].diceInMatch = numDices; 
    }


    function upgradeMatch(uint256 tokenId, uint8 numTurns, uint8 numDices, uint8 formpay) external payable {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of the token");
        require(_tokenDetails[tokenId].remainingMatch > 0 && _tokenDetails[tokenId].remainingMatch == numTurns, "This Cup have not active match");
        require(_tokenDetails[tokenId].wastage >= numTurns*(_tokenDetails[tokenId].diceInMatch+numDices), "You do not have sufficient waste!");
        require(numDices > 0 && _tokenDetails[tokenId].diceInMatch+numDices <= _tokenDetails[tokenId].rare, "Number of dices is incorrect");

        acceptedChips.upgradeMatch(msg.sender, numTurns, numDices, formpay);
        _tokenDetails[tokenId].diceInMatch += numDices;
    }


    function payTurns(address user) external Boardplay {
        uint256 totalCups = nextId;
        uint256 i;
        for (i = 0; i < totalCups; i++) {
            if (_exists(i) && ownerOf(i) == user && _tokenDetails[i].remainingMatch > 0 && _tokenDetails[i].wastage > 0) {
                _tokenDetails[i].remainingMatch -= 1;
                _tokenDetails[i].wastage -= _tokenDetails[i].diceInMatch;                
                if (_tokenDetails[i].remainingMatch == 0)
                    _tokenDetails[i].diceInMatch = 0;
            }
        }
    }


    function changeTurns(uint256 tokenId, uint256 turns, uint8 sum) external PVP {
        if (sum == 0) _tokenDetails[tokenId].remainingMatch -= turns;
        else _tokenDetails[tokenId].remainingMatch += turns;
    }


    function burnCup(address user, uint256 tokenId) external Boardplay returns (uint8) {
        require(user == ownerOf(tokenId), "User is not cup owner!");
        require(_tokenDetails[tokenId].wastage == 0, "Cup have uses!");

        uint8 rare = _tokenDetails[tokenId].rare;

        _burn(tokenId); //_transfer(user, address(0), tokenId);

        return rare;
    }



// Marketplace
    function sell(uint256 tokenId, uint256 tokenPrice) external {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of the token");
        require(_tokenDetails[tokenId].wastage > 0, "Your cup have not more uses!");
        require(tokenPrice > 0, "You can't sell free!");

        _transfer(msg.sender, address(this), tokenId);
        _tokenMarket[tokenId] = Listing(msg.sender, tokenPrice);
    }


    function unlisting(uint256 tokenId) external {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        require(ownerOf(tokenId) == address(this), "This token is not listing in Market");
        require(_tokenMarket[tokenId].seller == msg.sender, "You are not the owner of the token");

        _transfer(address(this), msg.sender, tokenId);
        _tokenMarket[tokenId].seller = address(0);
    }


    function buy(uint256 tokenId) external payable {
        require(maxNumberCups > getNumberItems(msg.sender), "You can't buy more cups!");
         require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        require(ownerOf(tokenId) == address(this), "This token is not listing in Market");
        address seller = _tokenMarket[tokenId].seller;
        require(seller != msg.sender, "You are the owner of the token");

        acceptedChips.buy(msg.sender, seller, _tokenMarket[tokenId].price);

        _transfer(address(this), msg.sender, tokenId);
        _tokenMarket[tokenId].seller = address(0);
    }


}