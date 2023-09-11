const { ethers } = require("hardhat");

const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const USDC_ADDRESS = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const USDC_DECIMALS = 6;
const FactoryAddress = "0x1F98431c8aD98523631AE4a59f267346ea31F984";

const ercAbi = [
    "function balanceOf(address owner) view returns (uint256)",
    "function transfer(address to, uint amount) returns (bool)",
    "function deposit() public payable",
    "function approve(address spender, uint256 amount) returns (bool)",
];

async function main() {
    const simpleSwapFactory = await ethers.getContractFactory("TestAllPools");
    console.log("Deploying contract...");
    const simpleSwap = await simpleSwapFactory.deploy(FactoryAddress);
    await simpleSwap.deploymentTransaction();

    let signers = await ethers.getSigners();
    const WETH = new ethers.Contract(WETH_ADDRESS, ercAbi, signers[0]);
    await WETH.deposit({ value: ethers.parseEther("100") });

    const USDC = new ethers.Contract(USDC_ADDRESS, ercAbi, signers[0]);
    const expandedUSDCBalanceBefore = await USDC.balanceOf(signers[0].address);
    const USDCBalanceBefore = Number(ethers.formatUnits(expandedUSDCBalanceBefore, USDC_DECIMALS));

    console.log(`USDC Balance: ${USDCBalanceBefore}`);

    await WETH.approve(await simpleSwap.getAddress(), ethers.parseEther("10"));
    const amountIn = ethers.parseEther("1");

    params = {
        tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        tokenOut: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        fee: 10000,
        amountIn: -amountIn,
        poolAddress: "0x7BeA39867e4169DBe237d55C8242a8f2fcDcc387",
    };

    await simpleSwap.swapTokens(params, { gasLimit: 1000000 });

    let expandedUSDCBalanceAfter = await USDC.balanceOf(signers[0].address);
    let USDCBalanceAfter = Number(ethers.formatUnits(expandedUSDCBalanceAfter, USDC_DECIMALS));
    let reduction = USDCBalanceAfter;

    console.log(`Uniswap(10000): `, USDCBalanceAfter);

    params = {
        tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        tokenOut: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        fee: 10000,
        amountIn: -amountIn,
        index: 2,
        poolAddress: "0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8",
    };

    await simpleSwap.swapTokens(params, { gasLimit: 1000000 });

    expandedUSDCBalanceAfter = await USDC.balanceOf(signers[0].address);
    USDCBalanceAfter = Number(ethers.formatUnits(expandedUSDCBalanceAfter, USDC_DECIMALS)) - reduction;
    reduction += USDCBalanceAfter;

    console.log(`Uniswap(3000): `, USDCBalanceAfter);

    params = {
        tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        tokenOut: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        fee: 10000,
        amountIn: -amountIn,
        index: 1,
        poolAddress: "0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640",
    };

    await simpleSwap.swapTokens(params, { gasLimit: 1000000 });

    expandedUSDCBalanceAfter = await USDC.balanceOf(signers[0].address);
    USDCBalanceAfter = Number(ethers.formatUnits(expandedUSDCBalanceAfter, USDC_DECIMALS)) - reduction;
    reduction += USDCBalanceAfter;

    console.log(`Uniswap(500): `, USDCBalanceAfter);

    params = {
        tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        tokenOut: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        fee: 10000,
        amountIn: -amountIn,
        index: 1,
        poolAddress: "0x763d3b7296e7C9718AD5B058aC2692A19E5b3638",
    };

    await simpleSwap.swapTokens(params, { gasLimit: 1000000 });

    expandedUSDCBalanceAfter = await USDC.balanceOf(signers[0].address);
    USDCBalanceAfter = Number(ethers.formatUnits(expandedUSDCBalanceAfter, USDC_DECIMALS)) - reduction;
    reduction += USDCBalanceAfter;

    console.log(`Sushiswap(3000): `, USDCBalanceAfter);

    params = {
        tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        tokenOut: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        fee: 10000,
        amountIn: -amountIn,
        index: 2,
        poolAddress: "0x1ac1A8FEaAEa1900C4166dEeed0C11cC10669D36",
    };

    await simpleSwap.swapTokens(params, { gasLimit: 1000000 });

    expandedUSDCBalanceAfter = await USDC.balanceOf(signers[0].address);
    USDCBalanceAfter = Number(ethers.formatUnits(expandedUSDCBalanceAfter, USDC_DECIMALS)) - reduction;
    reduction += USDCBalanceAfter;

    console.log(`Pancakeswap(500): `, USDCBalanceAfter);
}

main();
