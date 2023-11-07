// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { Overmint1_ERC1155, ExploitContract } from "../src/Overmint1-ERC1155.sol";

contract Overmint1_ERC1155Test is Test {
    ExploitContract exploitContract;
    Overmint1_ERC1155 overmint;

    function setUp() public {
        // Deploy "Overmint1_ERC1155" contract
        overmint = new Overmint1_ERC1155();

        // Deploy "ExploitContract"
        exploitContract = new ExploitContract();
    }

    function testOverMint() public {
        exploitContract.exploit(address(overmint));
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(overmint.success(address(exploitContract), 0));
    }
}