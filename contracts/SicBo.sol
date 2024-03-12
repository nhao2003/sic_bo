// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
contract SicBo {
    address public owner;
    uint[3] public dices;
    uint256 public totalBet;
    bool public isFinished = false;
    event BetEvent(address indexed player, uint256 amount, bool isOver);
    event SettleEvent(uint[3] dices);

    struct Bet {
        address player;
        uint256 amount;
        bool isOver;
    }

    Bet[] public bets;

    constructor() payable {
        require(
            msg.value >= 0.01 ether,
            "Initial balance must be greater than or equal to 0.01 ether"
        );
        owner = msg.sender;
    }

    function rollDices() private {
        for (uint i = 0; i < 3; i++) {
            dices[i] =
                (uint(
                    keccak256(
                        abi.encodePacked(block.timestamp, block.difficulty, i)
                    )
                ) % 6) +
                1;
        }
    }

    function bet(bool isOver) public payable {
        require(!isFinished, "Game is finished");
        require(msg.value > 0, "Bet amount must be greater than 0");
        require(
            msg.value <= 0.001 ether,
            "Bet amount must be less than or equal to 0.001 ether"
        );
        require(
            (msg.value + totalBet) * 2 <= address(this).balance,
            "Insufficient balance"
        );
        bets.push(Bet(msg.sender, msg.value, isOver));
        totalBet += msg.value;
        emit BetEvent(msg.sender, msg.value, isOver);
    }

    function settle() public returns (uint[3] memory) {
        require(!isFinished, "Game is finished");
        require(msg.sender == owner, "Only owner can settle the game");
        rollDices();
        emit SettleEvent(dices);
        uint sum = dices[0] + dices[1] + dices[2];
        for (uint i = 0; i < bets.length; i++) {
            if (!bets[i].isOver && sum < 11) {
                payable(bets[i].player).transfer(bets[i].amount * 2);
            } else if (bets[i].isOver && sum > 10) {
                payable(bets[i].player).transfer(bets[i].amount * 2);
            }
        }
        payable(owner).transfer(address(this).balance);
        isFinished = true;
        return dices;
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

    function getBetsByPlayer(
        address player
    ) public view returns (Bet[] memory) {
        Bet[] memory playerBets;
        uint count = 0;
        for (uint i = 0; i < bets.length; i++) {
            if (bets[i].player == player) {
                playerBets[count] = bets[i];
                count++;
            }
        }
        return playerBets;
    }

    function getTotalIsOverBets() public view returns (uint256) {
        uint256 total = 0;
        for (uint i = 0; i < bets.length; i++) {
            if (bets[i].isOver) {
                total += bets[i].amount;
            }
        }
        return total;
    }

    function getTotalIsUnderBets() public view returns (uint256) {
        uint256 total = 0;
        for (uint i = 0; i < bets.length; i++) {
            if (!bets[i].isOver) {
                total += bets[i].amount;
            }
        }
        return total;
    }
}
