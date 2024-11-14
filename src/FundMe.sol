// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 <0.9.0;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe_Not_Owner();

contract FundMe {
    using PriceConverter for uint256;
    address public immutable i_owner;
    address[] public funder;
    uint256 constant MIN_USD = 5 * 1e18;
    AggregatorV3Interface priceFeed;

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        i_owner = msg.sender;
    }

    mapping(address => uint) mapFunder;

    modifier OnlyOwner() {
        if (msg.sender != i_owner) revert FundMe_Not_Owner();
        _;
    }

    function getMinValue() public pure returns (uint256) {
        return MIN_USD;
    }

    function fundMe() public payable {
        require(
            msg.value.getEquivalentUSD(priceFeed) >= MIN_USD,
            "Sorry you cannot donate less than 5USD"
        );
        funder.push(msg.sender);
        mapFunder[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function withdraw() public OnlyOwner {
        for (uint256 i = 0; i < funder.length; i++) {
            address tempAdd = funder[i];
            mapFunder[tempAdd] = 0;
        }
        funder = new address[](0); // resetting the arrray
        (bool sent, ) = i_owner.call{value: address(this).balance}("");
        require(sent, "Failed Withdraw");
    }

    fallback() external payable {
        fundMe();
    }

    receive() external payable {
        fundMe();
    }
}
