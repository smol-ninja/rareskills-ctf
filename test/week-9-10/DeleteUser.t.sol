// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/DeleteUser.sol";

contract DeleteUserTest is Test {
    DeleteUser public deleteUser;

    ExploitContract public exploitContract;
    address public player = makeAddr("player");

    function setUp() public {
        // Deploy contracts
        deleteUser = new DeleteUser();
        deleteUser.deposit{value:  1 ether}();
    }

    function testIncrement() public {
        vm.deal(player, 1 ether);

        // Put your solution here
        vm.startPrank(player);
        exploitContract = new ExploitContract();
        exploitContract.exploit{value: 1 ether}(deleteUser);
        vm.stopPrank();
        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(address(deleteUser).balance, 0);
    }
}