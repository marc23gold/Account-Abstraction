//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address entryPoint;
        address account;
    }

    uint256 constant public ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 constant LOCAL_CHAIN_ID = 31337;
    address constant BURNER_WALLET = address(0xa83845bEeE92cA43E859DEFbC8c2d3Bd33232386);

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getEthSepoliaConfig();
    }

    function getConfig() public  returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public  returns (NetworkConfig memory) {
        if(chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else if (networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getEthSepoliaConfig() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: address(0x5FF137D40),
            account: BURNER_WALLET
        });
    }

    function getZkSyncSepoliaConfig() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: address(0),
            account: BURNER_WALLET

        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if(localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }
    }

}