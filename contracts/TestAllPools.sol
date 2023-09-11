// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import "@pancakeswap/v3-core/contracts/interfaces/callback/IPancakeV3SwapCallback.sol";
import "@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Pool.sol";

contract TestAllPools is IUniswapV3SwapCallback, IPancakeV3SwapCallback {
    // Dexes factories and WETH addresses
    IUniswapV3Factory uniswapFactory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
    IPancakeV3Factory pancakeswapFactory = IPancakeV3Factory(0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865);
    IUniswapV3Factory sushiswapFactory = IUniswapV3Factory(0xbACEB8eC6b9355Dfc0269C18bac9d6E2Bdc29C4F);
    IQuoterV2 uniswapQuoter = IQuoterV2(0x61fFE014bA17989E743c5F6cB21bF9697530B21e);
    IQuoterV2 pancakeswapQuoter = IQuoterV2(0x61fFE014bA17989E743c5F6cB21bF9697530B21e);
    IQuoterV2 sushiswapQuoter = IQuoterV2(0x64e8802FE490fa7cc61d3463958199161Bb608A7);
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapV3Factory factory;

    constructor(IUniswapV3Factory _factory) {
        factory = _factory;
    }

    struct SwapParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        int256 amountIn;
        address poolAddress;
    }

    struct SwapCallbackData {
        address token0;
        address token1;
        address poolAddress;
    }

    function swapTokens(SwapParams memory params) external {
        uint256 amountTransfer = uint256(-params.amountIn);
        TransferHelper.safeTransferFrom(WETH9, msg.sender, address(this), amountTransfer);

        IPancakeV3Pool pool = IPancakeV3Pool(params.poolAddress);
        (uint160 sqrtPriceX96Amout, , , , , , ) = pool.slot0();

        pool.swap(
            msg.sender,
            params.amountIn > 0,
            params.amountIn > 0 ? params.amountIn : -params.amountIn,
            sqrtPriceX96Amout * 2,
            abi.encode(SwapCallbackData({token0: params.tokenIn, token1: params.tokenOut, poolAddress: address(pool)}))
        );
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external override {
        SwapCallbackData memory decoded = abi.decode(data, (SwapCallbackData));
        //CallbackValidation.verifyCallback(address(factory), decoded.poolKey);

        address token0 = decoded.token0;
        address token1 = decoded.token1;

        if (amount0Delta > 0) TransferHelper.safeTransfer(token1, decoded.poolAddress, uint256(amount0Delta));

        if (amount1Delta > 0) TransferHelper.safeTransfer(token0, decoded.poolAddress, uint256(amount1Delta));
    }

    function pancakeV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external override {
        SwapCallbackData memory decoded = abi.decode(data, (SwapCallbackData));
        //CallbackValidation.verifyCallback(address(factory), decoded.poolKey);

        address token0 = decoded.token0;
        address token1 = decoded.token1;

        if (amount0Delta > 0) TransferHelper.safeTransfer(token1, decoded.poolAddress, uint256(amount0Delta));

        if (amount1Delta > 0) TransferHelper.safeTransfer(token0, decoded.poolAddress, uint256(amount1Delta));
    }
}
