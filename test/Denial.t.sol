// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Denial.sol";

contract DenialTest is Test {
    Denial public dripWallet;
    ExploitContract public exploitContract;

    // do not prank this address
    address owner = address(0xA9E);

    function setUp() public {
        // Deploy contracts
        dripWallet = new Denial();
        // deposit 100 ether into wallet
        vm.deal(address(dripWallet), 100 ether);

        // show that owner can withdraw his share
        dripWallet.withdraw();
        assertEq(owner.balance, 1 ether);

        exploitContract = new ExploitContract(dripWallet);
    }

    function testExploit() public {
        // Place your solution here
        dripWallet.setWithdrawPartner(address(exploitContract));
        _checkSolved();
    }

    function _checkSolved() internal {
        assertGt(address(dripWallet).balance, 0);

        // should revert on withdraw
        vm.expectRevert();
        dripWallet.withdraw{gas: 1000000}();
    }

    receive() external payable {}
}