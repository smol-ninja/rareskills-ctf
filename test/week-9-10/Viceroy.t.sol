// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/Viceroy.sol";

contract ViceroyTest is Test {
    OligarchyNFT public oligarch;
    Governance public governance;
    CommunityWallet public communityWallet;

    ExploitContract public exploitContract;
    address public player = makeAddr("player");

    function setUp() public {
        vm.deal(address(this), 1 ether);

        // Deploy contracts
        exploitContract = new ExploitContract();

        oligarch = new OligarchyNFT(address(exploitContract));
        governance = new Governance{value: 1 ether}(oligarch);
        communityWallet = governance.communityWallet();

        assertEq(address(communityWallet).balance, 1 ether);
    }

    function testIncrement() public {
        // Put your solution here
        exploitContract.exploit(governance);
        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(address(communityWallet).balance, 0);
        assertGe(address(exploitContract).balance, 1 ether);
    }
}