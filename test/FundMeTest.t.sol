// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    address USER = makeAddr("user"); //generate unique Ethereum Address based on String input.
    uint256 constant VALUE_SENT = 10e18;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    function setUp() external {
        DeployFundMe deployfundMe = new DeployFundMe(); // Deploy the FundMe contract
        fundme = deployfundMe.run(); // Assign the deployed FundMe contract instance
        vm.deal(USER, STARTING_BALANCE); // Provide balance to USER address (10 ether)
    }

    function testFundFailWithoutEnoughFund() external {
        vm.expectRevert(); // Expect the following statement to revert the transaction
        fundme.fundMe(); // Calling fundMe without enough funds should fail
    }

    function testChangesinFundMe() external {
        vm.prank(USER); // Simulate the transaction as if it's coming from USER address
        fundme.fundMe{value: VALUE_SENT}(); // USER sends VALUE_SENT ether to the contract
        uint256 amountFunded = fundme.getAddressAmountFund(USER); // Get the amount funded by USER
        assertEq(amountFunded, VALUE_SENT); // Assert that the amount funded equals VALUE_SENT
    }

    function testIfFunderisAddedInMap() external {
        vm.prank(USER); // Simulate the transaction as if it's coming from USER address
        fundme.fundMe{value: VALUE_SENT}(); // USER sends VALUE_SENT ether to the contract
        assertEq(fundme.getFunderWithIndex(0), USER); // Assert that USER's address is added as a funder at index 0
    }

    modifier funded() {
        vm.prank(USER); // Simulate the transaction as if it's coming from USER address
        fundme.fundMe{value: VALUE_SENT}(); // USER sends VALUE_SENT ether to the contract
        _; // Continue executing the function that uses this modifier
    }

    function testOnlyOwnerWithdraw() external funded {
        vm.expectRevert(); // Expect the following statement to revert the transaction
        vm.prank(USER); // Simulate the transaction as if it's coming from USER address (not the owner)
        fundme.withdraw(); // USER attempts to withdraw funds, but should fail (only owner can withdraw)
    }

    function testOwner() external view {
        assertEq(fundme.getOwner(), msg.sender); //the vm.broadcast(); make the msg.sender the owner if not then this contract would have been the owner as address(this)
    }

    function testOnlyOwnerCanWithdraw() external funded {
        //Arrage
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingContractBalance = address(fundme).balance;
        //Act
        // uint256 gasStarting = gasleft();
        // vm.txGasPrice(GAS_PRICE);//By default in anvil the gasPrice would be zero so gasPrice
        // vm.prank(fundme.getOwner());
        fundme.withdraw();
        // uint256 gasEnding = gasleft();
        // uint256 gasUsed = (gasStarting - gasEnding) * tx.gasprice;
        // console.log(gasUsed);
        //Assert
        uint256 endingContractBalance = address(fundme).balance;
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        assertEq(
            startingOwnerBalance + startingContractBalance,
            endingOwnerBalance
        );
        assertEq(endingContractBalance, 0);
    }

    function testWithMultipleFunders() external {
        //Assert
        uint160 numbersOfFunders = 10; //working with address just have uint160
        uint160 startingFundIndex = 1;
        for (uint160 i = startingFundIndex; i < numbersOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE); //hoax = vm.prank + vm.deal
            fundme.fundMe{value: STARTING_BALANCE}();
        }
        uint256 startingOwnerBalance = address(fundme.getOwner()).balance;
        uint256 startingContractBalance = address(fundme).balance;

        //Act
        vm.startPrank(fundme.getOwner()); //Starts impersonating the address returned by fundme.getOwner(), allowing the following actions to appear as if they are performed by this address
        fundme.withdraw();
        vm.stopPrank(); //Ends the impersonation started by vm.startPrank, returning to the original caller.

        //Assert
        assert(address(fundme).balance == 0);
        assert(
            startingContractBalance + startingOwnerBalance ==
                fundme.getOwner().balance
        );
    }

    function testVersion() external view {
        assertEq(fundme.getVersion(), 4); // Assert that the contract version is 4
    }
}
