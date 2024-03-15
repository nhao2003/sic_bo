// SPDX-License-Identifier: GPL-3.0

/**
 * @title SicBo
 * @dev A smart contract for a Sic Bo game.
 * @dev Players can place bets on the sum of the values of three dice.
 * @dev The game is settled by rolling the dice and comparing the sum to the bets placed by the players.
 * @dev The owner of the contract can settle the game and distribute the winnings to the players.
 */
pragma solidity >=0.8.2 <0.9.0;

contract SicBo {
    /// Adress of the owner of the contract.
    address public owner;
    /// Array of dice values.
    uint[3] public dices;
    /// Total amount of bets placed in the game.
    uint256 public totalBet;
    /// Boolean indicating whether the game is finished.
    bool public isFinished = false;
    /// Event emitted when a player places a bet.
    event BetEvent(address indexed player, uint256 amount, bool isOver);
    /// Event emitted when the game is settled.
    event SettleEvent(uint[3] dices);
    /// Array of bets placed in the game.
    mapping(bool => Bet[]) public betsMap;

    /// Struct representing a bet placed by a player.
    /// It contains the address of the player, the amount of the bet, and a boolean indicating whether the player is betting on the sum being over 10.
    struct Bet {
        address player;
        uint256 amount;
        bool isOver;
    }

    /**
     * @dev Constructor function.
     * @dev Sets the initial balance and owner of the contract.
     */
    constructor() payable {
        require(
            msg.value >= 0.0001 ether,
            "Initial balance must be greater than or equal to 0.0001 ether"
        );
        owner = msg.sender;
    }

    /**
     * @dev Generates random numbers for the dices.
     * @dev Private function, can only be called internally.
     */
    function rollDices() private {
        dices[0] =(uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 6) + 1;
        dices[1] =(uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 6) + 1;
        dices[2] =(uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 6) + 1;
    }

    /**
     * @dev Allows players to place bets on the game.
     * @param isOver A boolean indicating whether the player is betting on the sum being over 10.
     */
    function bet(bool isOver) public payable {
        require(!isFinished, "Game is finished");
        require(msg.value > 0, "Bet amount must be greater than 0");
        require(
            msg.value <= 0.00001 ether,
            "Bet amount must be less than or equal to 0.00001 ether"
        );
        require(
            (msg.value + totalBet) * 2 <= address(this).balance,
            "Insufficient balance"
        );
        Bet memory newBet = Bet(msg.sender, msg.value, isOver);
        betsMap[isOver].push(newBet);
        totalBet += msg.value;
        emit BetEvent(msg.sender, msg.value, isOver);
    }

    /**
     * @dev Settles the game and distributes the winnings to the players.
     */
    function settle() public {
        require(!isFinished, "Game is finished");
        require(msg.sender == owner, "Only owner can settle the game");
        rollDices();
        emit SettleEvent(dices);
        bool isOver = (dices[0] + dices[1] + dices[2]) > 10;
        Bet[] memory bets = betsMap[isOver];
        for (uint256 i = 0; i < bets.length; i++) {
            uint256 amount = bets[i].amount * 2;
            payable(bets[i].player).transfer(amount);
        }
        payable(owner).transfer(address(this).balance);
        isFinished = true;
        emit SettleEvent(dices);
    }

    /**
     * @dev Retrieves the current dice values.
     * @return The array of dice values.
     */
    function getDices() public view returns (uint[3] memory) {
        return dices;
    }

    /**
     * @dev Retrieves the list of bets placed in the game.
     * @return The array of bets.
     */
    function getBets() public view returns (Bet[][] memory) {
        Bet[][] memory bets = new Bet[][](2);
        bets[0] = betsMap[false];
        bets[1] = betsMap[true];
        return bets;
    }

    /**
     * @dev Retrieves the current balance of the contract.
     * @return The balance of the contract.
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
