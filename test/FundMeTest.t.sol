// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;

    function setUp() external {
        DeployFundMe deployfundMe = new DeployFundMe();//since we're using the deployFundMe and is powered by broadcast it default it to msg.sender the owner. 
        fundme = deployfundMe.run();
    }

    function testOwner() external view {
        assertEq(fundme.i_owner(), msg.sender); //basically this test deploy the contract so owner is this contract itself
    }

    function testVersion() external view {
        assertEq(fundme.getVersion(), 4);
    }
}
