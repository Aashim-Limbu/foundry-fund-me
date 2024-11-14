// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperconfig = new HelperConfig();
        address ethUSDpriceFeed = helperconfig.activeNetConfig();//quite strange like we don't need to destructure the address for one element in struct;
        //before broadcast you'll no longer need to spend gas on it for this initialization
        vm.startBroadcast();
        FundMe fundme = new FundMe(ethUSDpriceFeed); //Broadcast makes the owner default to msg.sender
        vm.stopBroadcast();
        return fundme;
    }
}
