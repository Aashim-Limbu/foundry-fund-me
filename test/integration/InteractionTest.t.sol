// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 <0.9.0;
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeInteractionsTest is Test {
    FundMe fundme;
    address alice = makeAddr("user"); //generate unique Ethereum Address based on String input.
    uint256 constant VALUE_SENT = 0.1e18;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployedFundMe = new DeployFundMe();
        fundme = deployedFundMe.run();
        // console.log("Owner: ", fundme.getOwner());//this is the default user assigned by the foundry
        vm.deal(alice, STARTING_BALANCE);
    }

    function testUserInteractions() public {
        FundFundMe fundFundme = new FundFundMe();
        fundFundme.fundFundMe(address(fundme));
        console.log("USER ADDRESS", alice);
        console.log("Address fundme", address(fundme));
        console.log("Contract Address", address(this));
        console.log("msg.sender", msg.sender);
        WithdrawFundMe withDrawFundme = new WithdrawFundMe();
        assertEq(address(fundme.getFunderWithIndex(0)), msg.sender);
        withDrawFundme.FundMeWithdraw(address(fundme));
        assert(address(fundme).balance == 0);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(alice).balance;
        uint256 preOwnerBalance = address(fundme.getOwner()).balance;

        // Using vm.prank to simulate funding from the USER address
        vm.prank(alice);
        fundme.fundMe{value: VALUE_SENT}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.FundMeWithdraw(address(fundme));

        uint256 afterUserBalance = address(alice).balance;
        uint256 afterOwnerBalance = address(fundme.getOwner()).balance;

        assert(address(fundme).balance == 0);
        assertEq(afterUserBalance + VALUE_SENT, preUserBalance);
        assertEq(preOwnerBalance + VALUE_SENT, afterOwnerBalance);
    }
}
