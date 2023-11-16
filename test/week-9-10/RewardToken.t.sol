// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/RewardToken.sol";

contract RewardTokenTest is Test {
    Depositoor public depositor;
    NftToStake public nft;
    RewardToken public token;

    Attacker public attacker;
    address public player = makeAddr("player");

    function setUp() public {
        // Deploy contracts
        attacker = new Attacker();
        nft = new NftToStake(address(attacker));
        depositor = new Depositoor(nft);
        token = new RewardToken(address(depositor));

        // setup
        depositor.setRewardToken(token);
    }

    function testIncrement() public {
        // Put your solution here
        vm.startPrank(player);

        attacker.stake(nft, depositor, 42);
        // wait for 10 days
        vm.warp(10 days);
        attacker.exploit(42);

        vm.stopPrank();
        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(token.balanceOf(address(attacker)), 100 ether);
        assertEq(token.balanceOf(address(depositor)), 0);
    }
}