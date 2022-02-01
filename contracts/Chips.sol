// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Chips {

// Token CLAP
    address public token_addr = 0xFf00811B621F8253792e794126a899689c93CDB3;
    IERC20 acceptedToken;




// Restrictions
    address public owner_address = msg.sender;
    modifier Owner() {
        require(
            msg.sender == owner_address,
            "This function is restricted to the contract's owner"
        );
        _;
    }

    address public dice_address;    function set_dice_address(address new_dice_address) public Owner { dice_address = new_dice_address; }
    address public cups_address;    function set_cups_address(address new_cups_address) public Owner { cups_address = new_cups_address; }
    modifier NFT() {
        require(
            msg.sender == dice_address || msg.sender == cups_address,
            "This function is restricted to the Dice and Cups Contracts"
        );
        _;
    }





// CLAP value
    uint256 clapValue = 10 ** 7; // 10 ** 8 = 1$
    function setClapValue(uint256 newClapValue) public Owner { clapValue = newClapValue; }

// Mint Price
    uint256 priceMint = 50 * 10 ** 8; // 50$
    function setPriceMint(uint256 newPriceMint) public Owner { priceMint = newPriceMint; }

// Marketplace Fee
    uint256 market_fee = 10;
    function set_market_fee(uint256 new_market_fee) public Owner { market_fee = new_market_fee; }

// Tax Fee
    uint256 tax_fee = 3;
    function set_tax_fee(uint256 new_tax_fee) public Owner { tax_fee = new_tax_fee; }

// Pool Address
    address public addressForPool = 0x8cad53767553A1f15d3F672e3C9c10eEcF4C867F;
    function set_addressForPool(address new_addressForPool) public Owner { addressForPool = new_addressForPool; }

// Earn
    uint256 earn = 10 * 10 ** 8; // 10$
    function set_earn(uint256 new_earn) public Owner { earn = new_earn; }

// Match
    uint256 priceLittleMatch = 10 * 10 ** 8;  // 10$
    function setPriceLittleMatch(uint256 newPriceLittleMatch) public Owner { priceLittleMatch = newPriceLittleMatch; }
    uint256 priceMediumMatch = 19 * 10 ** 8;  // 19$
    function setPriceMediumMatch(uint256 newPriceMediumMatch) public Owner { priceMediumMatch = newPriceMediumMatch; }
    uint256 priceBigMatch = 28 * 10 ** 8;  // 28$
    function setPriceBigMatch(uint256 newPriceBigMatch) public Owner { priceBigMatch = newPriceBigMatch; }
    uint256 percForDice = 75;
    function setPercForDice(uint256 newPercForDice) public Owner { percForDice = newPercForDice; }


// Airdrop testnet
        mapping(address => uint256) private _airdrop;


// Constructor
    constructor() {
        acceptedToken = IERC20(token_addr);
    }




// Random
    uint256 private nonce = 0;
    function _random() internal returns (uint256) {
        uint256 randomN = uint256(blockhash(block.number));
        uint256 index = uint256(keccak256(abi.encodePacked(randomN, block.timestamp, nonce)));
        nonce++;
        return index;
    }



    
// Chips
    mapping(address => uint256) private _userChips;

// Time
    mapping(address => uint256) private _userTime;






// Get
    function getUserChips(address userAddress) public view returns (uint256) { return _userChips[userAddress]; }

    function getTax(address userAddress) public view returns (uint256) {
        if (block.timestamp-_userTime[userAddress] < 86400) return tax_fee*15;
        else if (block.timestamp-_userTime[userAddress] < 86400*2) return tax_fee*14;
        else if (block.timestamp-_userTime[userAddress] < 86400*3) return tax_fee*13;
        else if (block.timestamp-_userTime[userAddress] < 86400*4) return tax_fee*12;
        else if (block.timestamp-_userTime[userAddress] < 86400*5) return tax_fee*11;
        else if (block.timestamp-_userTime[userAddress] < 86400*6) return tax_fee*10;
        else if (block.timestamp-_userTime[userAddress] < 86400*7) return tax_fee*9;
        else if (block.timestamp-_userTime[userAddress] < 86400*8) return tax_fee*8;
        else if (block.timestamp-_userTime[userAddress] < 86400*9) return tax_fee*7;
        else if (block.timestamp-_userTime[userAddress] < 86400*10) return tax_fee*6;
        else if (block.timestamp-_userTime[userAddress] < 86400*11) return tax_fee*5;
        else if (block.timestamp-_userTime[userAddress] < 86400*12) return tax_fee*4;
        else if (block.timestamp-_userTime[userAddress] < 86400*13) return tax_fee*3;
        else if (block.timestamp-_userTime[userAddress] < 86400*14) return tax_fee*2;
        else if (block.timestamp-_userTime[userAddress] < 86400*15) return tax_fee*1;
        else return 0;
    }

    function getClapValue() public view returns (uint256) {
        return clapValue;
    }


// Set
    struct Dice {
        uint8 rare; 
        uint8 tipo;
        uint8 [] faces;
    }
    function mintDice() external NFT returns (Dice memory) {
        uint seedr = _random() % 1000;
        uint8 rare = 1;
        if (seedr < 530) rare = 1;
        else if (seedr < 822) rare = 2;
        else if (seedr < 952) rare = 3;
        else if (seedr < 992) rare = 4;
        else if (seedr < 1000) rare = 5;

        uint seedt = _random() % 300;
        uint8 tipo = 1;
        if (seedt < 100) tipo = 1;
        else if (seedt < 200) tipo = 2;
        else if (seedt < 300) tipo = 3;

        uint8[] memory faces = new uint8[](rare);
        for (uint i = 0; i < rare; i++) {
            uint8 face = 1;
            uint seedf = _random() % 1000;
            if (tipo == 1) {
                if (seedf < 166) face = 1;
                else if (seedf < 332) face = 2;
                else if (seedf < 582) face = 3;
                else if (seedf < 666) face = 4;
                else if (seedf < 750) face = 5;
                else if (seedf < 1000) face = 6;
            } else if (tipo == 2) {
                if (seedf < 86) face = 1;
                else if (seedf < 336) face = 2;
                else if (seedf < 418) face = 3;
                else if (seedf < 584) face = 4;
                else if (seedf < 834) face = 5;
                else if (seedf < 1000) face = 6;
            } else {
                if (seedf < 250) face = 1;
                else if (seedf < 334) face = 2;
                else if (seedf < 500) face = 3;
                else if (seedf < 750) face = 4;
                else if (seedf < 916) face = 5;
                else if (seedf < 1000) face = 6;
            }
            faces[i] = face; 
        }
        return Dice(rare, tipo, faces);
    } 

    function mintCup() external NFT returns (uint8) {
        uint seedr = _random() % 1000;
        uint8 rare = 1;
        if (seedr < 530) rare = 1;
        else if (seedr < 822) rare = 2;
        else if (seedr < 952) rare = 3;
        else if (seedr < 992) rare = 4;
        else if (seedr < 1000) rare = 5;
        return rare;
    }

    function mint(address buyer) external NFT payable {
        uint256 amountClap = (priceMint / clapValue) * 10 ** 18;
        require(amountClap <= acceptedToken.balanceOf(buyer), "You need to buy more Clap!");
        require(acceptedToken.transferFrom(buyer, addressForPool, amountClap),"transfer Failed");
    }

    function buy(address buyer, address seller, uint256 price) external NFT payable {
        require(price <= acceptedToken.balanceOf(buyer), "You need to buy more Clap!");
        uint256 priceForSeller = price * (100-market_fee) / 100;
        uint256 priceForPool = price - priceForSeller;
        require(acceptedToken.transferFrom(buyer, seller, priceForSeller),"transfer Failed");
        require(acceptedToken.transferFrom(buyer, addressForPool, priceForPool),"transfer Failed");
    }

    function startMatch(address buyer, uint8 typematch, uint8 numDices, uint8 formpay) external NFT payable {
        uint256 costMatch;
        if (typematch == 1) costMatch = (priceLittleMatch / clapValue) * 10 ** 18;
        else if (typematch == 2) costMatch = (priceMediumMatch / clapValue) * 10 ** 18;
        else costMatch = (priceBigMatch / clapValue) * 10 ** 18;
        costMatch += costMatch * (numDices-1) * percForDice / 100;
        if (formpay == 0) { //pay with $CLAP
            require(costMatch <= acceptedToken.balanceOf(buyer), "You need to buy more Clap!");
            require(acceptedToken.transferFrom(buyer, addressForPool, costMatch),"transfer Failed");
        } else { //pay with $CHIPS
            require(costMatch <= _userChips[buyer], "You need to have more Chips!");
            _userChips[buyer] -= costMatch;
        }
    }

    function upgradeMatch(address buyer, uint8 numTurns, uint8 numDices, uint8 formpay) external NFT payable {
        uint256 costMatch = percForDice * numTurns * numDices * ((priceLittleMatch / 10) / clapValue) * 10 ** 18 / 100; 
        if (formpay == 0) { //pay with $CLAP
            require(costMatch <= acceptedToken.balanceOf(buyer), "You need to buy more Clap!");
            require(acceptedToken.transferFrom(buyer, addressForPool, costMatch),"transfer Failed");
        } else { //pay with $CHIPS
            require(costMatch <= _userChips[buyer], "You need to have more Chips!");
            _userChips[buyer] -= costMatch;
        }
    }

    function boardPlay(address user, uint256 result) external NFT {
        if (_userTime[user] == 0) _userTime[user] = block.timestamp;

        uint256 percVictory = 1000;
        if (result==0) percVictory = 5;
        else if (result==1) percVictory = 100;
        else if (result==2) percVictory = 150;
        else if (result==3) percVictory = 225;
        else if (result==4) percVictory = 325;
        else if (result==5) percVictory = 450;
        else if (result==6) percVictory = 600;
        else if (result==7) percVictory = 775;
        else if (result==8) percVictory = 975;

        _userChips[user] += (earn / clapValue) * percVictory * 10 ** 18 / 100;
    }


    function burn(address user, uint256 result, uint256 rareCup) external NFT {
        uint256 percVictory = 1000;
        if (result==0) percVictory = 5;
        else if (result==1) percVictory = 100;
        else if (result==2) percVictory = 150;
        else if (result==3) percVictory = 225;
        else if (result==4) percVictory = 325;
        else if (result==5) percVictory = 450;
        else if (result==6) percVictory = 600;
        else if (result==7) percVictory = 775;
        else if (result==8) percVictory = 975;

        uint256 perc = percVictory / 2;

        _userChips[user] += (earn / clapValue) * perc * (2 + rareCup) * 10 ** 18 / 100;
    }


    function claim(address user) external {
        require(msg.sender == user, "You are not user!");

        uint256 earnings = _userChips[user] * (100-getTax(user)) / 100;
        require(acceptedToken.transferFrom(addressForPool, user, earnings),"transfer Failed");

        _userChips[user] = 0;
        _userTime[user] = block.timestamp;
    }


    function testnetAirdrop() external {
        require(_airdrop[msg.sender] == 0, "You do not claim tokens two times!");
        require(acceptedToken.transferFrom(addressForPool, msg.sender, 10000  * 10 ** 18),"transfer Failed");
        _airdrop[msg.sender] = 1;
    }

}