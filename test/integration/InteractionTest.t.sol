// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 <0.9.0;
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
// contract FundMeInteractionTest is Test {
//     FundMe fundme;
//     address USER = makeAddr("user"); //generate unique Ethereum Address based on String input.
//     uint256 constant VALUE_SENT = 10e18;
//     uint256 constant STARTING_BALANCE = 10 ether;
//     uint256 constant GAS_PRICE = 1;
//     function setUp() external {
//         DeployFundMe deployedFundMe = new DeployFundMe();
//         fundme = deployedFundMe.run();
//         vm.deal(USER, STARTING_BALANCE);
//     }
//     function testUserCanFundInteractions() public {
//         FundFundMe fundFundme = new FundFundMe();
//         vm.prank(USER);
//         vm.deal(USER,STARTING_BALANCE);
//         fundFundme.fundFundMe(address(fundme));
//         address funder = fundme.getFunderWithIndex(0);
//         assertEq(funder, USER);
//     }
// }
contract FundMeInteractionsTest is Test {
    FundMe fundme;
    address USER = makeAddr("user"); //generate unique Ethereum Address based on String input.
    uint256 constant VALUE_SENT = 10e18;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    function setUp() external {
        DeployFundMe deployedFundMe = new DeployFundMe();
        fundme = deployedFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testUserCanWithdrawInteractions() public {
        FundFundMe fundFundme = new FundFundMe();
        fundFundme.fundFundMe(address(fundme));

        WithdrawFundMe withDrawFundme = new WithdrawFundMe();
        withDrawFundme.FundMeWithdraw(address(fundme));
        assert(address(fundme).balance == 0);
    }
}
