// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SideEntranceLenderPool.sol";

contract SideEntranceLenderPoolTest is Test {
    SideEntranceLenderPool public pool;
    ExploitContract public exploitContract;

    uint256 constant public ETHER_IN_POOL = 1000 ether;
    // do not prank deployer except in setUp
    address deployer = makeAddr("deployer");

    function setUp() public {
        // Deploy contracts
        pool = new SideEntranceLenderPool();

        vm.deal(deployer, ETHER_IN_POOL);
        vm.prank(deployer);
        pool.deposit{value: ETHER_IN_POOL}();

        vm.deal(address(this), 1 ether);
        exploitContract = new ExploitContract(pool);
    }

    function testExploit() public {
        // Place your solution here
        exploitContract.exploit();
        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(address(pool).balance, 0);
        assertGt(address(this).balance, ETHER_IN_POOL);
    }

    receive() external payable {}
}