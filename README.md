# Intro

This is the first version of my liquidity aggregator demo smart contract. It's objective is to get all the WETH/USDC pools on Uniswap, Pancakeswap and Sushiswap, find the pool with the best ratio for a swap of WETH to USDC and execute the swap of 1 WETH for the maximum amount of USDC possible.

In this repository we have 2 smart contract and 2 scripts one of each for testing a swap on all pools, and making the main swap on the best pool.

# Env Setup

1.Install yarn for simplicity.

```npm install --global yarn```

2.Install the dependencies.

```yarn install```

3.Create a .env with an enviromentla var FORK_RPC_URL with your RPC for forking mainet. Or alternativaly substitute FORK_RPC_URL on hardhat.config.js with your RPC.

```FORK_RPC_URL = https://eth-mainnet.g.alchemy.com/v2/123abc```

# Running the contracts

1.Compile the contracts.

```yarn hardhat compile```

2.Create a node in hardhat to run the forked mainnet.

```yarn hardhat node```

3.Open a second terminal and run the test.js script. It will make a swap at each one of the pool and return the amount of tokens that would be received as result.

<img width="805" alt="image" src="https://github.com/Nerzilus/liquidity-aggregator-demo/assets/66218208/e46d95a0-3336-48a9-a8f8-b1a786bf8c78">

4.Now run the swap.js script, it will return the amount of tokens resuilting in swaping on the best pool.

<img width="801" alt="image" src="https://github.com/Nerzilus/liquidity-aggregator-demo/assets/66218208/bfccee33-e4f6-43f5-afa7-0cca246ce72b">

