// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract GuessTheSecretNumber {
    bytes32 answerHash =
        0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable returns (bool) {
        require(msg.value == 1 ether);

        if (keccak256(abi.encodePacked(n)) == answerHash) {
            (bool ok, ) = msg.sender.call{value: 2 ether}("");
            require(ok, "Failed to Send 2 ether");
        }
        return true;
    }
}

// Write your exploit codes below
contract ExploitContract {
    bytes32 answerHash =
        0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    /**
     * The exploit is a result of low number of values that `uint8` holds [0, 256).
     * Since we know that `answerHash` is a hash of n, we can just loop over all the
     * values of `uint8` to find the secret number without running out of gas
     */
    function Exploiter() public view returns (uint8 n) {
        for (uint i; i < 256;) {
            if (keccak256(abi.encodePacked(uint8(i))) == answerHash) {
                return uint8(i);
            }
            unchecked {
                ++i;
            }
        }
    }
}