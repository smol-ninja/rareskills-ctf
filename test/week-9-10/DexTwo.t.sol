// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/DexTwo.sol";

contract DexTwoTest is Test {
    DexTwo public dex;
    SwappableTokenTwo public token1;
    SwappableTokenTwo public token2;

    ExploitContract public exploitContract;
    address public player = makeAddr("player");

    function setUp() public {
        // Deploy contracts
        dex = new DexTwo();
        token1 = new SwappableTokenTwo(address(dex), "token1", "token1", 110);
        token2 = new SwappableTokenTwo(address(dex), "token1", "token1", 110);

        // setup dex
        dex.setTokens(address(token1), address(token2));
        dex.approve(address(dex), 100);
        dex.add_liquidity(address(token1), 100);
        dex.add_liquidity(address(token2), 100);

        // transfer 10 tokens to player
        token1.transfer(player, 10);
        token2.transfer(player, 10);
    }

    function testIncrement() public {
        // Put your solution here
        vm.startPrank(player);

        exploitContract = new ExploitContract();
        dex.approve(address(exploitContract), 10);
        exploitContract.exploit(token1, token2, dex);

        vm.stopPrank();
        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(token1.balanceOf(address(dex)), 0);
        assertEq(token2.balanceOf(address(dex)), 0);
    }
}