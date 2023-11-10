// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/week-9-10/Truster.sol";
import "../../src/utilities/DamnValuableToken.sol";

contract TrusterTest is Test {
    TrusterLenderPool public pool;
    DamnValuableToken public token;
    Exploiter public exploiter;

    uint256 public constant TOKENS_IN_POOL = 1_000_000e18;

    function setUp() public {
        // Deploy contracts
        token = new DamnValuableToken();
        pool = new TrusterLenderPool(token);

        token.transfer(address(pool), TOKENS_IN_POOL);

        exploiter = new Exploiter();
    }

    function testIncrement() public {
        // Put your solution here
        exploiter.exploit(pool, token, TOKENS_IN_POOL);
        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(token.balanceOf(address(exploiter)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), 0);
    }
}