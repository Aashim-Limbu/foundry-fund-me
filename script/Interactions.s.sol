// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address MostRecentlyDeployedVersion) public {
        vm.startBroadcast();
        FundMe(payable(MostRecentlyDeployedVersion)).fundMe{
            value: SEND_VALUE
        }();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        vm.startBroadcast();
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.stopBroadcast();
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    function FundMeWithdraw(address MostRecenltyDeployedVersions) public {
        vm.startBroadcast();
        FundMe(payable(MostRecenltyDeployedVersions)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployedContract = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        FundMeWithdraw(mostRecentlyDeployedContract);
        vm.stopBroadcast();
    }
}
