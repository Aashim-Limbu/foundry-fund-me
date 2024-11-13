// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 <0.9.0;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe_Not_Owner();

contract FundMe {
    using PriceConverter for uint256;
    address private immutable i_owner;
    address[] public funder;
    uint256 constant MIN_USD = 5 * 1e18;

    constructor() {
        i_owner = msg.sender;
    }

    mapping(address => uint) mapFunder;

    modifier OnlyOwner() {
        if (msg.sender != i_owner) revert FundMe_Not_Owner();
        _;
    }

    function fundMe() public payable {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        require(
            msg.value.getEquivalentUSD(priceFeed) >= MIN_USD,
            "Sorry you cannot donate less than 5USD"
        );
        funder.push(msg.sender);
        mapFunder[msg.sender] += msg.value;
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
