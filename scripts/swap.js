const { ethers } = require("hardhat");

const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const USDC_ADDRESS = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const USDC_DECIMALS = 6;

const ercAbi = [
    "function balanceOf(address owner) view returns (uint256)",
    "function transfer(address to, uint amount) returns (bool)",
    "function deposit() public payable",
    "function approve(address spender, uint256 amount) returns (bool)",
];

async function main() {
    const simpleSwapFactory = await ethers.getContractFactory("LiquidityAggregator");
    console.log("Deploying contract...");
    const simpleSwap = await simpleSwapFactory.deploy();
    await simpleSwap.deploymentTransaction();

    let signers = await ethers.getSigners();
    const WETH = new ethers.Contract(WETH_ADDRESS, ercAbi, signers[0]);
    const deposit = await WETH.deposit({ value: ethers.parseEther("10") });

    const USDC = new ethers.Contract(USDC_ADDRESS, ercAbi, signers[0]);
    const expandedUSDCBalanceBefore = await USDC.balanceOf(signers[0].address);
    const USDCBalanceBefore = Number(ethers.formatUnits(expandedUSDCBalanceBefore, USDC_DECIMALS));

    console.log(`USDC Balance: ${USDCBalanceBefore}`);

    await WETH.approve(await simpleSwap.getAddress(), ethers.parseEther("1"));
    const amountIn = ethers.parseEther("1");

    params = {
        tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        tokenOut: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        amountIn: -amountIn,
    };

    const swap = await simpleSwap.swapTokens(params, { gasLimit: 1000000 });

    const expandedUSDCBalanceAfter = await USDC.balanceOf(signers[0].address);
    const USDCBalanceAfter = Number(ethers.formatUnits(expandedUSDCBalanceAfter, USDC_DECIMALS));

    console.log(USDCBalanceAfter);
}

main();
