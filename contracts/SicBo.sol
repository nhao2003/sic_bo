// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
contract SicBo {
    address public owner;
    uint[3] public dices;
    uint256 public totalBet;

    struct Bet {
        address player;
        uint amount;
        bool isOver;
    }

    Bet[] public bets;

    constructor() payable {
        require(msg.value >= 1 ether, "Initial balance must be greater than 1");
        owner = msg.sender;
    }

    function rollDices() private {
        for (uint i = 0; i < 3; i++) {
            dices[i] = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, i))) % 6 + 1;
        }
    }

    function bet(bool isOver) public payable {
        require(msg.value > 0, "Bet amount must be greater than 0");
        require(msg.value <= 0.01 ether, "Bet amount must be less than 0.01 ether");
        require((msg.value + totalBet) * 2 <= address(this).balance, "Insufficient balance");
        bets.push(Bet(msg.sender, msg.value, isOver));
    }

    function settle() public returns (uint[3] memory) {
        require(msg.sender == owner, "Only owner can settle the game");
        rollDices();
        uint sum = dices[0] + dices[1] + dices[2];
        for (uint i = 0; i < bets.length; i++) {
            if (!bets[i].isOver && sum < 11) {
                payable(bets[i].player).transfer(bets[i].amount * 2);
            } else if (bets[i].isOver && sum > 10) {
                payable(bets[i].player).transfer(bets[i].amount * 2);
            }
        }
        return dices;
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(address(this).balance > 0, "Balance must be greater than 0");
        payable(owner).transfer(address(this).balance);
    }

    function getDices() public view returns (uint[3] memory) {
        return dices;
    }

    function getBets() public view returns (Bet[] memory) {
        return bets;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}