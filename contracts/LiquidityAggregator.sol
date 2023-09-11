// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import "@pancakeswap/v3-core/contracts/interfaces/callback/IPancakeV3SwapCallback.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract LiquidityAggregator is IUniswapV3SwapCallback, IPancakeV3SwapCallback {
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public owner;

    mapping(IUniswapV3Factory => uint24[]) private factoryFees;
    IUniswapV3Factory[3] private factories;
    IQuoterV2[3] private quoters;

    constructor() {
        owner = msg.sender;

        factories[0] = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
        factories[1] = IUniswapV3Factory(0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865);
        factories[2] = IUniswapV3Factory(0xbACEB8eC6b9355Dfc0269C18bac9d6E2Bdc29C4F);

        factoryFees[factories[0]] = [10000, 3000, 500];
        factoryFees[factories[1]] = [10000, 2500, 500, 100];
        factoryFees[factories[2]] = [3000];

        quoters[0] = IQuoterV2(0x61fFE014bA17989E743c5F6cB21bF9697530B21e);
        quoters[1] = IQuoterV2(0xB048Bbc1Ee6b733FFfCFb9e9CeF7375518e25997);
        quoters[2] = IQuoterV2(0x64e8802FE490fa7cc61d3463958199161Bb608A7);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    struct SwapParams {
        address tokenIn;
        address tokenOut;
        int256 amountIn;
    }

    struct SwapCallbackData {
        address token0;
        address token1;
        address poolAddress;
    }

    function quoterGetAmountOut(
        IQuoterV2 quoter,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint24 fee,
        uint160 sqrtPriceLimitX96
    ) public returns (uint256 sqrtPriceX96After) {
        IQuoterV2.QuoteExactInputSingleParams memory quoterParams = IQuoterV2.QuoteExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amountIn: amountIn,
            fee: fee,
            sqrtPriceLimitX96: sqrtPriceLimitX96
        });
        (uint256 amountOut, , , ) = quoter.quoteExactInputSingle(quoterParams);

        return amountOut;
    }

    function getBestPool(SwapParams memory params) public returns (address bestPool) {
        uint256 amountInQuoter = uint256(-params.amountIn);

        address pool;
        uint256 amount = 0;
        uint256 bestAmount = 0;

        for (uint256 i = 0; i < factories.length; i++) {
            for (uint256 j = 0; j < factoryFees[factories[i]].length; j++) {
                pool = (factories[i].getPool(params.tokenIn, params.tokenOut, factoryFees[factories[i]][j]));
                if (address(pool) != address(0)) {
                    amount = quoterGetAmountOut(
                        quoters[i],
                        params.tokenIn,
                        params.tokenOut,
                        amountInQuoter,
                        factoryFees[factories[i]][j],
                        0
                    );

                    if (amount > bestAmount) {
                        bestAmount = amount;
                        bestPool = pool;
                    }
                }
            }
        }
        return bestPool;
    }

    function swapTokens(SwapParams memory params) external onlyOwner {
        uint256 amountTransfer = uint256(-params.amountIn);
        TransferHelper.safeTransferFrom(WETH9, msg.sender, address(this), amountTransfer);

        address bestPool;
        bestPool = getBestPool(params);

        IPancakeV3Pool pool = IPancakeV3Pool(bestPool);
        (uint160 sqrtPriceX96Amout, , , , , , ) = pool.slot0();

        pool.swap(
            msg.sender,
            params.amountIn > 0,
            params.amountIn > 0 ? params.amountIn : -params.amountIn,
            sqrtPriceX96Amout * 2,
            abi.encode(SwapCallbackData({token0: params.tokenIn, token1: params.tokenOut, poolAddress: address(pool)}))
        );
    }

    function mainCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) public {
        SwapCallbackData memory decoded = abi.decode(data, (SwapCallbackData));
        //CallbackValidation.verifyCallback(address(factory), decoded.poolKey);

        address token0 = decoded.token0;
        address token1 = decoded.token1;

        if (amount0Delta > 0) TransferHelper.safeTransfer(token1, decoded.poolAddress, uint256(amount0Delta));

        if (amount1Delta > 0) TransferHelper.safeTransfer(token0, decoded.poolAddress, uint256(amount1Delta));
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external override {
        mainCallback(amount0Delta, amount1Delta, data);
    }

    function pancakeV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external override {
        mainCallback(amount0Delta, amount1Delta, data);
    }
}
