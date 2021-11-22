const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config();
const mnemonic = process.env.MNEMONIC;
const rinkebyInfuraKey = process.env.RINKEBYINFURAKEY;

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 7545, // Standard Ethereum port (default: none)
      network_id: "5777", // Any network (default: none)
      from: "0xF4BAb87AAA0f2191e6aF9C7228716Eb4BeB839FC",
    },
    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, "https://ropsten.infura.io/v3/f7602f629b114e1294d3a0d676411708"),
      network_id: 3,
      networkCheckTimeout: 10000,
      confirmations: 1,
      timeoutBlocks: 2000,
      gas: 8000000,
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
      // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    rinkeby: {
      provider: () => new HDWalletProvider(mnemonic, rinkebyInfuraKey),
      network_id: 4,
      gas: 8000000,
      gasPrice: 240000000000,
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },
    mainnet: {
      provider: () => new HDWalletProvider(mnemonic, mainnetInfuraKey, 0),
      network_id: 1,
      gas: 8000000,
      gasPrice: 240000000000,
      timeoutBlocks: 5000000, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },
  },
  //
  // Configure your compilers
  compilers: {
    solc: {
      version: "0.6.6", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: false,
          runs: 200,
        },
        //  evmVersion: "byzantium"
      },
    },
  },

  plugins: ["truffle-plugin-verify"],
  api_keys: {
    etherscan: "", // Add  API key
  },
};
