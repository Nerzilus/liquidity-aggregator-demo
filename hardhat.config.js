require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

const FORK_RPC_URL = process.env.FORK_RPC_URL;

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
            forking: {
                url: FORK_RPC_URL,
            },
        },
    },
    solidity: {
        compilers: [
            {
                version: "0.7.6",
            },
        ],
    },
};
