//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MinimalAccount} from "../src/Eth/MinimalAccount.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract MimimalAccountScript is Script {
    function run() public {

    }

    function deployMinimalAccount() public returns (HelperConfig, MinimalAccount ){
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast();
        MinimalAccount minimalAccount = new MinimalAccount(config.account);
        minimalAccount.transferOwnership(msg.sender);
        vm.stopBroadcast();
        return (helperConfig, minimalAccount);
    }
}