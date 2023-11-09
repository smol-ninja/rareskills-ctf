// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { NaughtCoin, ExploitContract } from "../../src/week-7-8/NaughtCoin.sol";

contract NaughtCoinTest is Test {
    NaughtCoin public naughtCoin;
    ExploitContract public exploitContract;

    uint256 public constant INITIAL_SUPPLY = 1000000e18;
    address public otherUser = address(1234);

    function setUp() public {
        naughtCoin = new NaughtCoin(address(this));
        exploitContract = new ExploitContract();

        assertEq(naughtCoin.balanceOf(address(this)), INITIAL_SUPPLY);
        // check that player cannot transfer balance
        vm.expectRevert();
        naughtCoin.transfer(otherUser, INITIAL_SUPPLY);
    }

    function testExploit() public {
        // Place your solution here
        naughtCoin.approve(address(exploitContract), INITIAL_SUPPLY);
        exploitContract.exploit(address(naughtCoin), INITIAL_SUPPLY);
        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(naughtCoin.balanceOf(address(this)), 0);
        assertEq(naughtCoin.balanceOf(otherUser), INITIAL_SUPPLY);
        vm.prank(otherUser);
        naughtCoin.transfer(address(0xDEAD), INITIAL_SUPPLY);
    }
}