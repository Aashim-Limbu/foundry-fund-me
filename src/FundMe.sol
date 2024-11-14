// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 <0.9.0;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe_Not_Owner();

contract FundMe {
    using PriceConverter for uint256;
    address private immutable i_owner;
    address[] private s_funder;
    uint256 constant MIN_USD = 5 * 1e18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address _priceFeed) {
        s_priceFeed = AggregatorV3Interface(_priceFeed);
        i_owner = msg.sender;
    }

    mapping(address => uint) private s_mapFunder;

    modifier OnlyOwner() {
        if (msg.sender != i_owner) revert FundMe_Not_Owner();
        _;
    }

    function getMinValue() public pure returns (uint256) {
        return MIN_USD;
    }

    function fundMe() public payable {
        require(
            msg.value.getEquivalentUSD(s_priceFeed) >= MIN_USD,
            "Sorry you cannot donate less than 5USD"
        );
        s_funder.push(msg.sender);
        s_mapFunder[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public OnlyOwner {
        for (uint256 i = 0; i < s_funder.length; i++) {
            address tempAdd = s_funder[i];
            s_mapFunder[tempAdd] = 0;
        }
        s_funder = new address[](0); // resetting the arrray
        (bool sent, ) = i_owner.call{value: address(this).balance}("");
        require(sent, "Failed Withdraw");
    }

    fallback() external payable {
        fundMe();
    }

    receive() external payable {
        fundMe();
    }

    //PureFunction Getters
    function getAddressAmountFund(
        address funder
    ) external view returns (uint256) {
        return s_mapFunder[funder];
    }

    function getFunderWithIndex(uint256 idx) external view returns (address) {
        return s_funder[idx];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
