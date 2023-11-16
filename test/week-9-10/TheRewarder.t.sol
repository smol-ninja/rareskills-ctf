// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/the-rewarder/ReadOnly.sol";

contract ReadOnlyTest is Test {
    ReadOnlyPool public pool;
    VulnerableDeFiContract public vulnerableContract;

    Attacker public attacker;
    address public player = makeAddr("player");

    function setUp() public {
        // Deploy contracts
        pool = new ReadOnlyPool();
        vulnerableContract = new VulnerableDeFiContract(pool);

        // setup
        pool.addLiquidity{value: 100 ether}();
        pool.earnProfit{value: 1 ether}();
        vulnerableContract.snapshotPrice();

        // player starts with 2 ether
        vm.deal(player, 2 ether);
    }

    function testIncrement() public {
        // Put your solution here
        vm.startPrank(player);

        attacker = new Attacker(pool, vulnerableContract);
        attacker.exploit{value:  2 ether}();

        vm.stopPrank();
        _checkSolved();
    }

    function _checkSolved() internal {
        console.logUint(vulnerableContract.lpTokenPrice());
        assertEq(vulnerableContract.lpTokenPrice(), 0);
    }
}