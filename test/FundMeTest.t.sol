// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe";
contract FundMeTest is Test {
    uint number = 1;
    function setUp() external {
        number = 2;
    }
    function testDemo() public view {
        console.log(number);
        console.log("Hey running test moron");
        assertEq(number, 2);
    }
}
