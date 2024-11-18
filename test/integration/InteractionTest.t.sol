// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 <0.9.0;
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeInteractionsTest is Test {
    FundMe fundme;
    address USER = makeAddr("user"); //generate unique Ethereum Address based on String input.
    uint256 constant VALUE_SENT = 0.1e18;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployedFundMe = new DeployFundMe();
        fundme = deployedFundMe.run();
        // console.log("Owner: ", fundme.getOwner());//this is the default user assigned by the foundry
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        FundFundMe fundFundme = new FundFundMe();
        fundFundme.fundFundMe(address(fundme));
        console.log("USER ADDRESS", USER);
        console.log("Address fundme", address(fundme));
        console.log("Contract Address", address(this));
        console.log("msg.sender", msg.sender);
        WithdrawFundMe withDrawFundme = new WithdrawFundMe();
        assertEq(address(fundme.getFunderWithIndex(0)), msg.sender);
        withDrawFundme.FundMeWithdraw(address(fundme));
        assert(address(fundme).balance == 0);
    }
}
