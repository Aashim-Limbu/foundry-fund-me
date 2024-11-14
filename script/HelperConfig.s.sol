// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 <0.9.0;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

//It allow us to test different datafeed address in local chain.
//We'll no longer need to make an API call to alchemy thus reducing the billing cost.
contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
    }
    NetworkConfig public activeNetConfig;
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8;
    constructor() {
        if (block.chainid == 11155111) {
            activeNetConfig = getSepoliaEthConfig();
        } else {
            activeNetConfig = getAnvilConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getAnvilConfig() public pure returns (NetworkConfig memory) {

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig  memory anvilConfig = NetworkConfig({priceFeed:address(mockPriceFeed)});
    }
}
