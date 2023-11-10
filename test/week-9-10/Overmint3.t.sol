// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/Overmint3.sol";

contract Overmint3Test is Test {
    Overmint3 public overmint;
    Exploiter public exploiter;

    function setUp() public {
        // Deploy contracts
        overmint = new Overmint3();

        exploiter = new Exploiter();
    }

    function testIncrement() public {
        // Put your solution here
        exploiter.exploit(overmint);
        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(overmint.balanceOf(address(exploiter)), 5);
    }
}