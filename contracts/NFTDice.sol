// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Chips.sol";


contract NFTDice is ERC721 {


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



// Chips
    address public chips_addr = 0x4D2744a7070F07154EDc0097F8A64265389136E2;
    Chips acceptedChips;



// Constructor
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
            acceptedChips = Chips(chips_addr);
    }



// NFT Information
    struct Dice {
        uint8 rare; 
        uint8 tipo;
        uint8 [] faces;
        uint8 wastage;
    }
    mapping( uint256 => Dice) private _tokenDetails;
    uint256 nextId = 0;
  
    uint256 maxNumberDices = 10;
    function setMaxNumberDices(uint256 newMaxNumberDices) public Owner {
        maxNumberDices = newMaxNumberDices;
    }

    uint256 maxTotalDices = 200;
    function setTotalDices(uint256 newTotalDices) public Owner {
        maxTotalDices = newTotalDices;
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
    function getNumberMintedDice() public view returns (uint256) {
        return nextId;
    }


    function getTokenDetails(uint256 tokenId) public view returns (Dice memory) { return _tokenDetails[tokenId]; }
   
   
    function getAllTokensForUser(address user) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(user);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint[] memory result = new uint256[](tokenCount);
            uint256 totalDices = nextId;
            uint256 resultIndex = 0;
            uint256 i;
            for (i = 0; i < totalDices; i++) {
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
            uint256 totalDices = nextId;
            uint256 resultIndex = 0;
            uint256 i;
            for (i = 0; i < totalDices; i++) {
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
        uint256 totalDices = nextId;
        ListingAux [] memory result = new ListingAux [](totalDices);
        uint256 i;
        for (i = 0; i < totalDices; i++) {
            if (_tokenMarket[i].seller != address(0)) {
                result[i] = ListingAux(i, _tokenMarket[i].seller, _tokenMarket[i].price);
            }
        }
        return result;
    }


    function getNumberItems(address user) public view returns (uint256) {
        uint256 totalDices = nextId;
        uint256 numDices = balanceOf(user);
        uint256 i;
        for (i = 0; i < totalDices; i++) {
            if (_tokenMarket[i].seller == user) numDices += 1;
        }
        return numDices;
    }


    function getResultsDices(address user, uint256[] memory conjDices, uint8 number) public view returns (uint256) {
        uint256 result = 0;
        uint256 i = 0;
        for (i = 0; i < conjDices.length; i++) {
            require(user == ownerOf(conjDices[i]), "User is not dice owner!");
            require(_tokenDetails[conjDices[i]].wastage > 0, "Dice have not uses!");
            uint8[] memory faces = _tokenDetails[conjDices[i]].faces;
            uint256 j = 0;
            for (j = 0; j < faces.length; j++) {
                if (faces[j] == number+1) result += 1;
            }
        }
        return result;
    }



// Sets
    function mint() external payable {
        require(maxTotalDices > nextId, "it is not allowed to mine more dice!");
        require(maxNumberDices > getNumberItems(msg.sender), "You can't mint more dice!");
        
        if (mintInBNB == 1) {
            require(msg.value == priceBNB, "Failed to send BNB");
            payable(acceptedChips.get_addressForPool()).transfer(priceBNB);
        } else {
            acceptedChips.mint(msg.sender);
        }

        Chips.Dice memory dice = acceptedChips.mintDice();
        _tokenDetails[nextId] = Dice(dice.rare, dice.tipo, dice.faces, 100);

        _safeMint(msg.sender, nextId);
        nextId++;
    }


    function playBoardGame(address user, uint256[] memory conjDices, uint8 number) external Boardplay {
        uint256 result = getResultsDices(user, conjDices, number);

        uint256 i = 0;
        for (i = 0; i < conjDices.length; i++) {
            _tokenDetails[conjDices[i]].wastage -= 1;
        }

        acceptedChips.boardPlay(user, result);
    }


    function burnDice(address user, uint256 tokenId, uint8 rareCup, uint8 number) external Boardplay {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        require(user == ownerOf(tokenId), "User is not dice owner!");
        require(_tokenDetails[tokenId].wastage == 0, "Dice have uses!");
        
        uint256 result = 0;
        uint8[] memory faces = _tokenDetails[tokenId].faces;
        uint256 j = 0;
        for (j = 0; j < faces.length; j++) {
            if (faces[j] == number+1) result += 1;
        }

        _burn(tokenId); //_transfer(user, address(0), tokenId);

        acceptedChips.burn(user, result, rareCup);
    } 



// Marketplace
    function sell(uint256 tokenId, uint256 tokenPrice) external {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of the token");
        require(_tokenDetails[tokenId].wastage > 0, "Your dice have not more uses!");
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
        require(maxNumberDices > getNumberItems(msg.sender), "You can't buy more dice!");
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        require(ownerOf(tokenId) == address(this), "This token is not listing in Market");
        address seller = _tokenMarket[tokenId].seller;
        require(seller != msg.sender, "You are the owner of the token");

        acceptedChips.buy(msg.sender, seller, _tokenMarket[tokenId].price);

        _transfer(address(this), msg.sender, tokenId);
        _tokenMarket[tokenId].seller = address(0);
    }


}