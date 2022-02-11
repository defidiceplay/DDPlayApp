// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./NFTCups.sol";
import "./NFTDice.sol";


contract Boardplay  {


// Restrictions
    address public owner_address = msg.sender;
    modifier Owner() {
        require(
            msg.sender == owner_address,
            "This function is restricted to the contract's owner"
        );
        _;
    }



// Cooldowns
    mapping(address => uint256) public _cooldowns;

// Randomizer
    mapping(address => uint256[]) public _randomizer;

// Results
    mapping(address => uint256) public _results;



// NFT Contracts
    NFTCups acceptedCups;
    address public cups_addr = 0x09ab263bD322a721d28F3EbB18620fD3011EbcB9;
    NFTDice acceptedDice;
    address public dice_addr = 0x0F117Ec8d21b4D8Cf0378506d4e2bB7D9d325471;



// Constructor
    constructor() {
        acceptedCups = NFTCups(cups_addr);
        acceptedDice = NFTDice(dice_addr);
    }



// Get
    function getResult() public view returns (uint256) {
        return _results[msg.sender]; 
    }


    function getCooldown() public view returns (uint256) {
        return block.timestamp - _cooldowns[msg.sender]; 
    }



// Random
    uint256 private nonce = 0;
    function _random() internal returns (uint256) {
        uint256 randomN = uint256(blockhash(block.number));
        uint256 index = uint256(uint256(keccak256(abi.encodePacked(randomN, block.timestamp, nonce))) % 1296);
        nonce++;
        return index;
    }



// Set
    function boardPlay_1_0(uint256[] memory conjDices) external payable {
        if (_cooldowns[msg.sender] == 0) {
            uint[] memory newRandomizer = new uint[](6);
            uint256 k = 0; for (k = 0; k < 6; k++) { newRandomizer[k] = 216; }
            _randomizer[msg.sender] = newRandomizer;
        }
        require(conjDices.length > 0, "No dice");
        require(acceptedCups.getCapacity(msg.sender) >= conjDices.length, "A lot of dice");
        require(block.timestamp >= _cooldowns[msg.sender] + 86400, "Not yet for play!");

        uint8 face = 5;
        uint256 number = _random();
        if (number < _randomizer[msg.sender][0]) face = 0;
        else if (number < _randomizer[msg.sender][0]+_randomizer[msg.sender][1]) face = 1;
        else if (number < _randomizer[msg.sender][0]+_randomizer[msg.sender][1]+_randomizer[msg.sender][2]) face = 2;
        else if (number < _randomizer[msg.sender][0]+_randomizer[msg.sender][1]+_randomizer[msg.sender][2]+_randomizer[msg.sender][3]) face = 3;
        else if (number < _randomizer[msg.sender][0]+_randomizer[msg.sender][1]+_randomizer[msg.sender][2]+_randomizer[msg.sender][3]+_randomizer[msg.sender][4]) face = 4;

        acceptedDice.playBoardGame(msg.sender, conjDices, face);

        acceptedCups.payTurns(msg.sender);

        uint256 i = 0; 
        for (i = 0; i < 6; i++) { 
            if (i == face) _randomizer[msg.sender][i] -= 5;
            else _randomizer[msg.sender][i] += 1;
        }
        _cooldowns[msg.sender] = block.timestamp;

        _results[msg.sender] = face;
    }



    function burn(uint256 dice, uint8 is_cup, uint256 cup) external {
        uint8 rareCup = 0;
        if (is_cup > 0)
            rareCup = acceptedCups.burnCup(msg.sender, cup);

        uint256 face = _random() % 6;
        acceptedDice.burnDice(msg.sender, dice, rareCup, uint8(face));
         
        _results[msg.sender] = face;
    }


}