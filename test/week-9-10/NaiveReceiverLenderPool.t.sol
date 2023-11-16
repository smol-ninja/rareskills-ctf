// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/naive-receiver/NaiveReceiverLenderPool.sol";
import "../../src/week-9-10/naive-receiver/NaiveFlashLoanReceiver.sol";

contract NaiveReceiverTest is Test {
    NaiveReceiverLenderPool public pool;
    FlashLoanReceiver public receiver;

    uint private constant ETHER_IN_POOL = 1000 ether;
    uint private constant ETHER_IN_RECEIVER = 10 ether;
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    ExploitContract public exploitContract;
    address public player = makeAddr("player");

    function setUp() public {
        // Deploy contracts
        pool = new NaiveReceiverLenderPool();
        payable(pool).transfer(ETHER_IN_POOL);

        assertEq(address(pool).balance, ETHER_IN_POOL);
        assertEq(pool.maxFlashLoan(ETH), ETHER_IN_POOL);
        assertEq(pool.flashFee(ETH, 0), 1 ether);

        receiver = new FlashLoanReceiver(address(pool));
        payable(receiver).transfer(ETHER_IN_RECEIVER);
        
        vm.expectRevert();
        receiver.onFlashLoan(address(this), ETH, ETHER_IN_RECEIVER, 1 ether, "0x");
        assertEq(address(receiver).balance, ETHER_IN_RECEIVER);
    }

    function testIncrement() public {
        // Put your solution here
        vm.startPrank(player);

        exploitContract = new ExploitContract();
        exploitContract.exploit(pool, receiver, ETH);

        vm.stopPrank();
        _checkSolved();
    }

    function _checkSolved() internal {
        // All ETH has been drained from the receiver
        assertEq(address(receiver).balance, 0);
        assertEq(address(pool).balance, ETHER_IN_POOL + ETHER_IN_RECEIVER);
    }
}