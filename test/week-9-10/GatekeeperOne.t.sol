// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/GatekeeperOne.sol";

contract GatekeeperOneTest is Test {
    GatekeeperOne public gatekeeper;

    ExploitContract public exploitContract;
    address public player = makeAddr("player");

    function setUp() public {
        // Deploy contracts
        gatekeeper = new GatekeeperOne();
    }

    function testIncrement() public {
        // Put your solution here
        vm.startPrank(player);

        exploitContract = new ExploitContract();
        bytes8 key = exploitContract.exploit(gatekeeper);
        console.logBytes8(key);

        vm.stopPrank();
    }
}