// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../../src/week-9-10/selfie/SimpleGovernance.sol";
import "../../src/week-9-10/selfie/SelfiePool.sol";
import "../../src/week-9-10/selfie/Attacker.sol";

contract SelfieTest is Test {
    DamnValuableTokenSnapshot private token;
    SimpleGovernance private governance;
    SelfiePool private pool;

    uint private constant TOKEN_INITIAL_SUPPLY = 2_000_000e18;
    uint private constant TOKENS_IN_POOL = 1_500_000e18;

    Attacker public attacker;
    address public player = makeAddr("player");

    function setUp() public {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        // Deploy contracts
        token = new DamnValuableTokenSnapshot(TOKEN_INITIAL_SUPPLY);
        governance = new SimpleGovernance(address(token));
        pool = new SelfiePool(address(token), address(governance));

        // Fund the pool
        token.transfer(address(pool), TOKENS_IN_POOL);
        token.snapshot();

        // asserts
        assertEq(governance.getActionCounter(), 1);
        assertEq(address(pool.token()), address(token));
        assertEq(address(pool.governance()), address(governance));
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(pool.maxFlashLoan(address(token)), TOKENS_IN_POOL);
        assertEq(pool.flashFee(address(token), 0), 0);
    }

    function testIncrement() public {
        /** CODE YOUR SOLUTION HERE */
        vm.startPrank(player);

        attacker = new Attacker();
        uint actionId = attacker.exploit(pool, governance, token, TOKENS_IN_POOL);

        // forward time by ACTION_DELAY_IN_SECONDS
        skip(governance.getActionDelay());
        attacker.execute(governance, actionId);

        vm.stopPrank();
        _checkSolved();
    }

    function _checkSolved() internal {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
        assertEq(token.balanceOf(address(attacker)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), 0);
    }
}