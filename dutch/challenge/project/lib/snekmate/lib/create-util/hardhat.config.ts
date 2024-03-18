import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-verify";
import "@nomicfoundation/hardhat-ledger";
import "@typechain/hardhat";
import "xdeployer";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-contract-sizer";
import "hardhat-abi-exporter";

dotenv.config();

task("accounts", "Prints the list of accounts", async (_, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task(
  "balances",
  "Prints the list of accounts and their balances",
  async (_, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
      console.log(
        account.address +
          " " +
          (await hre.ethers.provider.getBalance(account.address)),
      );
    }
  },
);

const config: HardhatUserConfig = {
  solidity: {
    // Only use Solidity versions `>=0.8.20` for EVM networks that support the opcode `PUSH0`
    // Otherwise, use the versions `<=0.8.19`
    version: "0.8.21",
    settings: {
      optimizer: {
        enabled: true,
        runs: 999999,
      },
      evmVersion: "paris", // Prevent using the `PUSH0` opcode
    },
  },
  networks: {
    hardhat: {
      initialBaseFeePerGas: 0,
      chainId: 31337,
      hardfork: "shanghai",
      forking: {
        url: process.env.ETH_MAINNET_URL || "",
        // The Hardhat network will by default fork from the latest mainnet block
        // To pin the block number, specify it below
        // You will need access to a node with archival data for this to work!
        // blockNumber: 14743877,
        // If you want to do some forking, set `enabled` to true
        enabled: false,
      },
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    tenderly: {
      url: `https://rpc.tenderly.co/fork/${process.env.TENDERLY_FORK_ID}`,
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    devnet: {
      url: `https://rpc.vnet.tenderly.co/devnet/${process.env.TENDERLY_DEVNET_ID}`,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    goerli: {
      chainId: 5,
      url: process.env.ETH_GOERLI_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    sepolia: {
      chainId: 11155111,
      url: process.env.ETH_SEPOLIA_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    holesky: {
      chainId: 17000,
      url: process.env.ETH_HOLESKY_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    ethMain: {
      chainId: 1,
      url: process.env.ETH_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    bscTestnet: {
      chainId: 97,
      url: process.env.BSC_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    bscMain: {
      chainId: 56,
      url: process.env.BSC_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    optimismTestnet: {
      chainId: 420,
      url: process.env.OPTIMISM_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    optimismMain: {
      chainId: 10,
      url: process.env.OPTIMISM_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    arbitrumTestnet: {
      chainId: 421613,
      url: process.env.ARBITRUM_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    arbitrumSepolia: {
      chainId: 421614,
      url: process.env.ARBITRUM_SEPOLIA_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    arbitrumMain: {
      chainId: 42161,
      url: process.env.ARBITRUM_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    arbitrumNova: {
      chainId: 42170,
      url: process.env.ARBITRUM_NOVA_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    mumbai: {
      chainId: 80001,
      url: process.env.POLYGON_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    polygonZkEVMTestnet: {
      chainId: 1442,
      url: process.env.POLYGON_ZKEVM_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    polygon: {
      chainId: 137,
      url: process.env.POLYGON_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    polygonZkEVMMain: {
      chainId: 1101,
      url: process.env.POLYGON_ZKEVM_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    hecoTestnet: {
      chainId: 256,
      url: process.env.HECO_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    hecoMain: {
      chainId: 128,
      url: process.env.HECO_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    fantomTestnet: {
      chainId: 4002,
      url: process.env.FANTOM_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    fantomMain: {
      chainId: 250,
      url: process.env.FANTOM_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    fuji: {
      chainId: 43113,
      url: process.env.AVALANCHE_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    avalanche: {
      chainId: 43114,
      url: process.env.AVALANCHE_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    sokol: {
      chainId: 77,
      url: process.env.SOKOL_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    chiado: {
      chainId: 10200,
      url: process.env.GNOSIS_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    gnosis: {
      chainId: 100,
      url: process.env.GNOSIS_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    moonbaseAlpha: {
      chainId: 1287,
      url: process.env.MOONBEAM_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    moonriver: {
      chainId: 1285,
      url: process.env.MOONRIVER_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    moonbeam: {
      chainId: 1284,
      url: process.env.MOONBEAM_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    alfajores: {
      chainId: 44787,
      url: process.env.CELO_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    celo: {
      chainId: 42220,
      url: process.env.CELO_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    auroraTestnet: {
      chainId: 1313161555,
      url: process.env.AURORA_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    auroraMain: {
      chainId: 1313161554,
      url: process.env.AURORA_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    harmonyTestnet: {
      chainId: 1666700000,
      url: process.env.HARMONY_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    harmonyMain: {
      chainId: 1666600000,
      url: process.env.HARMONY_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    spark: {
      chainId: 123,
      url: process.env.FUSE_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    fuse: {
      chainId: 122,
      url: process.env.FUSE_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    cronosTestnet: {
      chainId: 338,
      url: process.env.CRONOS_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    cronosMain: {
      chainId: 25,
      url: process.env.CRONOS_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    evmosTestnet: {
      chainId: 9000,
      url: process.env.EVMOS_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    evmosMain: {
      chainId: 9001,
      url: process.env.EVMOS_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    bobaTestnet: {
      chainId: 2888,
      url: process.env.BOBA_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    bobaMain: {
      chainId: 288,
      url: process.env.BOBA_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    cantoTestnet: {
      chainId: 7701,
      url: process.env.CANTO_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    cantoMain: {
      chainId: 7700,
      url: process.env.CANTO_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    baseTestnet: {
      chainId: 84531,
      url: process.env.BASE_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    baseMain: {
      chainId: 8453,
      url: process.env.BASE_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    mantleTestnet: {
      chainId: 5001,
      url: process.env.MANTLE_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    mantleMain: {
      chainId: 5000,
      url: process.env.MANTLE_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    filecoinTestnet: {
      chainId: 314159,
      url: process.env.FILECOIN_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    scrollTestnet: {
      chainId: 534353,
      url: process.env.SCROLL_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    lineaTestnet: {
      chainId: 59140,
      url: process.env.LINEA_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    lineaMain: {
      chainId: 59144,
      url: process.env.LINEA_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    shimmerEVMTestnet: {
      chainId: 1071,
      url: process.env.SHIMMEREVM_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    zoraTestnet: {
      chainId: 999,
      url: process.env.ZORA_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    zoraMain: {
      chainId: 7777777,
      url: process.env.ZORA_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    luksoTestnet: {
      chainId: 4201,
      url: process.env.LUKSO_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    luksoMain: {
      chainId: 42,
      url: process.env.LUKSO_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    mantaTestnet: {
      chainId: 3441005,
      url: process.env.MANTA_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    mantaMain: {
      chainId: 169,
      url: process.env.MANTA_MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    shardeumTestnet: {
      chainId: 8081,
      url: process.env.SHARDEUM_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
    artheraTestnet: {
      chainId: 10243,
      url: process.env.ARTHERA_TESTNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      ledgerAccounts:
        process.env.LEDGER_ACCOUNT !== undefined
          ? [process.env.LEDGER_ACCOUNT]
          : [],
    },
  },
  xdeploy: {
    contract: "Create",
    constructorArgsPath: undefined,
    salt: process.env.SALT,
    signer: process.env.PRIVATE_KEY,
    networks: ["goerli", "sepolia"],
    rpcUrls: [
      process.env.ETH_GOERLI_TESTNET_URL,
      process.env.ETH_SEPOLIA_TESTNET_URL,
    ],
    gasLimit: 1.2 * 10 ** 6,
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
    strict: true,
    only: [],
    except: [],
  },
  abiExporter: {
    path: "./abis",
    runOnCompile: true,
    clear: true,
    flat: false,
    only: [],
    spacing: 2,
    pretty: true,
  },
  etherscan: {
    apiKey: {
      // For Ethereum testnets & mainnet
      mainnet: process.env.ETHERSCAN_API_KEY || "",
      goerli: process.env.ETHERSCAN_API_KEY || "",
      sepolia: process.env.ETHERSCAN_API_KEY || "",
      holesky: process.env.ETHERSCAN_API_KEY || "",
      // For BSC testnet & mainnet
      bsc: process.env.BSC_API_KEY || "",
      bscTestnet: process.env.BSC_API_KEY || "",
      // For Heco testnet & mainnet
      heco: process.env.HECO_API_KEY || "",
      hecoTestnet: process.env.HECO_API_KEY || "",
      // For Fantom testnet & mainnet
      opera: process.env.FANTOM_API_KEY || "",
      ftmTestnet: process.env.FANTOM_API_KEY || "",
      // For Optimism testnet & mainnet
      optimisticEthereum: process.env.OPTIMISM_API_KEY || "",
      optimisticGoerli: process.env.OPTIMISM_API_KEY || "",
      // For Polygon testnets & mainnets
      polygon: process.env.POLYGON_API_KEY || "",
      polygonZkEVM: process.env.POLYGON_ZKEVM_API_KEY || "",
      polygonMumbai: process.env.POLYGON_API_KEY || "",
      polygonZkEVMTestnet: process.env.POLYGON_ZKEVM_API_KEY || "",
      // For Arbitrum testnets & mainnets
      arbitrumOne: process.env.ARBITRUM_API_KEY || "",
      arbitrumNova: process.env.ARBITRUM_API_KEY || "",
      arbitrumGoerli: process.env.ARBITRUM_API_KEY || "",
      arbitrumSepolia: process.env.ARBITRUM_API_KEY || "",
      // For Avalanche testnet & mainnet
      avalanche: process.env.AVALANCHE_API_KEY || "",
      avalancheFujiTestnet: process.env.AVALANCHE_API_KEY || "",
      // For Moonbeam testnet & mainnets
      moonbeam: process.env.MOONBEAM_API_KEY || "",
      moonriver: process.env.MOONBEAM_API_KEY || "",
      moonbaseAlpha: process.env.MOONBEAM_API_KEY || "",
      // For Harmony testnet & mainnet
      harmony: process.env.HARMONY_API_KEY || "",
      harmonyTest: process.env.HARMONY_API_KEY || "",
      // For Aurora testnet & mainnet
      aurora: process.env.AURORA_API_KEY || "",
      auroraTestnet: process.env.AURORA_API_KEY || "",
      // For Cronos testnet & mainnet
      cronos: process.env.CRONOS_API_KEY || "",
      cronosTestnet: process.env.CRONOS_API_KEY || "",
      // For Gnosis/xDai testnets & mainnets
      gnosis: process.env.GNOSIS_API_KEY || "",
      xdai: process.env.GNOSIS_API_KEY || "",
      sokol: process.env.GNOSIS_API_KEY || "",
      chiado: process.env.GNOSIS_API_KEY || "",
      // For Fuse testnet & mainnet
      fuse: process.env.FUSE_API_KEY || "",
      spark: process.env.FUSE_API_KEY || "",
      // For Evmos testnet & mainnet
      evmos: process.env.EVMOS_API_KEY || "",
      evmosTestnet: process.env.EVMOS_API_KEY || "",
      // For Boba network testnet & mainnet
      boba: process.env.BOBA_API_KEY || "",
      bobaTestnet: process.env.BOBA_API_KEY || "",
      // For Canto testnet & mainnet
      canto: process.env.CANTO_API_KEY || "",
      cantoTestnet: process.env.CANTO_API_KEY || "",
      // For Base testnet & mainnet
      base: process.env.BASE_API_KEY || "",
      baseTestnet: process.env.BASE_API_KEY || "",
      // For Mantle testnet & mainnet
      mantle: process.env.MANTLE_API_KEY || "",
      mantleTestnet: process.env.MANTLE_API_KEY || "",
      // For Scroll testnet
      scrollTestnet: process.env.SCROLL_API_KEY || "",
      // For Linea testnet & mainnet
      linea: process.env.LINEA_API_KEY || "",
      lineaTestnet: process.env.LINEA_API_KEY || "",
      // For ShimmerEVM testnet
      shimmerEVMTestnet: process.env.SHIMMEREVM_API_KEY || "",
      // For Zora testnet & mainnet
      zora: process.env.ZORA_API_KEY || "",
      zoraTestnet: process.env.ZORA_API_KEY || "",
      // For Lukso testnet & mainnet
      lukso: process.env.LUKSO_API_KEY || "",
      luksoTestnet: process.env.LUKSO_API_KEY || "",
      // For Manta testnet & mainnet
      manta: process.env.MANTA_API_KEY || "",
      mantaTestnet: process.env.MANTA_API_KEY || "",
      // For Arthera testnet
      artheraTestnet: process.env.ARTHERA_API_KEY || "",
    },
    customChains: [
      {
        network: "holesky",
        chainId: 17000,
        urls: {
          apiURL: "https://api-holesky.etherscan.io/api",
          browserURL: "https://holesky.etherscan.io",
        },
      },
      {
        network: "chiado",
        chainId: 10200,
        urls: {
          apiURL: "https://gnosis-chiado.blockscout.com/api",
          browserURL: "https://gnosis-chiado.blockscout.com",
        },
      },
      {
        network: "cronos",
        chainId: 25,
        urls: {
          apiURL: "https://api.cronoscan.com/api",
          browserURL: "https://cronoscan.com",
        },
      },
      {
        network: "cronosTestnet",
        chainId: 338,
        urls: {
          apiURL: "https://cronos.org/explorer/testnet3/api",
          browserURL: "https://cronos.org/explorer/testnet3",
        },
      },
      {
        network: "fuse",
        chainId: 122,
        urls: {
          apiURL: "https://explorer.fuse.io/api",
          browserURL: "https://explorer.fuse.io",
        },
      },
      {
        network: "spark",
        chainId: 123,
        urls: {
          apiURL: "https://explorer.fusespark.io/api",
          browserURL: "https://explorer.fusespark.io",
        },
      },
      {
        network: "evmos",
        chainId: 9001,
        urls: {
          apiURL: "https://escan.live/api",
          browserURL: "https://escan.live",
        },
      },
      {
        network: "evmosTestnet",
        chainId: 9000,
        urls: {
          apiURL: "https://testnet.escan.live/api",
          browserURL: "https://testnet.escan.live",
        },
      },
      {
        network: "boba",
        chainId: 288,
        urls: {
          apiURL: "https://api.bobascan.com/api",
          browserURL: "https://bobascan.com",
        },
      },
      {
        network: "bobaTestnet",
        chainId: 2888,
        urls: {
          apiURL: "https://api-testnet.bobascan.com/api",
          browserURL: "https://testnet.bobascan.com",
        },
      },
      {
        network: "arbitrumNova",
        chainId: 42170,
        urls: {
          apiURL: "https://api-nova.arbiscan.io/api",
          browserURL: "https://nova.arbiscan.io",
        },
      },
      {
        network: "arbitrumSepolia",
        chainId: 421614,
        urls: {
          apiURL: "https://sepolia-explorer.arbitrum.io/api",
          browserURL: "https://sepolia-explorer.arbitrum.io",
        },
      },
      {
        network: "canto",
        chainId: 7700,
        urls: {
          apiURL: "https://tuber.build/api",
          browserURL: "https://tuber.build",
        },
      },
      {
        network: "cantoTestnet",
        chainId: 7701,
        urls: {
          apiURL: "https://testnet.tuber.build/api",
          browserURL: "https://testnet.tuber.build",
        },
      },
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org",
        },
      },
      {
        network: "baseTestnet",
        chainId: 84531,
        urls: {
          apiURL: "https://api-goerli.basescan.org/api",
          browserURL: "https://goerli.basescan.org",
        },
      },
      {
        network: "mantle",
        chainId: 5000,
        urls: {
          apiURL: "https://explorer.mantle.xyz/api",
          browserURL: "https://explorer.mantle.xyz",
        },
      },
      {
        network: "mantleTestnet",
        chainId: 5001,
        urls: {
          apiURL: "https://explorer.testnet.mantle.xyz/api",
          browserURL: "https://explorer.testnet.mantle.xyz",
        },
      },
      {
        network: "scrollTestnet",
        chainId: 534353,
        urls: {
          apiURL: "https://blockscout.scroll.io/api",
          browserURL: "https://blockscout.scroll.io",
        },
      },
      {
        network: "polygonZkEVM",
        chainId: 1101,
        urls: {
          apiURL: "https://api-zkevm.polygonscan.com/api",
          browserURL: "https://zkevm.polygonscan.com",
        },
      },
      {
        network: "polygonZkEVMTestnet",
        chainId: 1442,
        urls: {
          apiURL: "https://api-testnet-zkevm.polygonscan.com/api",
          browserURL: "https://testnet-zkevm.polygonscan.com",
        },
      },
      {
        network: "linea",
        chainId: 59144,
        urls: {
          apiURL: "https://api.lineascan.build/api",
          browserURL: "https://lineascan.build",
        },
      },
      {
        network: "lineaTestnet",
        chainId: 59140,
        urls: {
          apiURL: "https://api-testnet.lineascan.build/api",
          browserURL: "https://goerli.lineascan.build",
        },
      },
      {
        network: "shimmerEVMTestnet",
        chainId: 1071,
        urls: {
          apiURL: "https://explorer.evm.testnet.shimmer.network/api",
          browserURL: "https://explorer.evm.testnet.shimmer.network",
        },
      },
      {
        network: "zora",
        chainId: 7777777,
        urls: {
          apiURL: "https://explorer.zora.energy/api",
          browserURL: "https://explorer.zora.energy",
        },
      },
      {
        network: "zoraTestnet",
        chainId: 999,
        urls: {
          apiURL: "https://testnet.explorer.zora.energy/api",
          browserURL: "https://testnet.explorer.zora.energy",
        },
      },
      {
        network: "lukso",
        chainId: 42,
        urls: {
          apiURL: "https://explorer.execution.mainnet.lukso.network/api",
          browserURL: "https://explorer.execution.mainnet.lukso.network",
        },
      },
      {
        network: "luksoTestnet",
        chainId: 4201,
        urls: {
          apiURL: "https://explorer.execution.testnet.lukso.network/api",
          browserURL: "https://explorer.execution.testnet.lukso.network",
        },
      },
      {
        network: "manta",
        chainId: 169,
        urls: {
          apiURL: "https://pacific-explorer.manta.network/api",
          browserURL: "https://pacific-explorer.manta.network",
        },
      },
      {
        network: "mantaTestnet",
        chainId: 3441005,
        urls: {
          apiURL: "https://pacific-explorer.testnet.manta.network/api",
          browserURL: "https://pacific-explorer.testnet.manta.network",
        },
      },
      {
        network: "artheraTestnet",
        chainId: 10243,
        urls: {
          apiURL: "https://explorer-test.arthera.net/api",
          browserURL: "https://explorer-test.arthera.net",
        },
      },
    ],
  },
};

export default config;
