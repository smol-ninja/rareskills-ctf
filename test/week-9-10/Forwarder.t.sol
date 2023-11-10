// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/Forwarder.sol";

contract ForwarderTest is Test {
    Forwarder public forwarder;
    Wallet public wallet;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        forwarder = new Forwarder();
        wallet = new Wallet{value: 1 ether}(address(forwarder));

        exploitContract = new ExploitContract();
    }

    function testIncrement() public {
        // Put your solution here
        exploitContract.exploit(forwarder, address(wallet));
        _checkSolved();
    }

    function _checkSolved() internal {
        uint256 attackerWalletBalance = address(exploitContract).balance;
        assertTrue(attackerWalletBalance >= 1 ether - 1e15 && attackerWalletBalance <= 1 ether + 1e15);
        assertEq(address(wallet).balance, 0);
    }
}