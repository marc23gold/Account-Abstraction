//SPDX-Liecense-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "../../src/Eth/MinimalAccount.sol";
import {MimimalAccountScript} from "../../script/MinimalAccountScript.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "../../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp, PackedUserOperation} from "../../script/SendPackedUserOp.s.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccountTest is Test {
    using MessageHashUtils for bytes32;

    HelperConfig helperConfig;
    MinimalAccount minimalAccount;
    ERC20Mock usdc;
    SendPackedUserOp sendPackedUserOp;

    uint256 constant AMOUNT = 1e18;
    address randomUser = makeAddr("randomUser");

    function setUp() public {
        MimimalAccountScript deployMinimal = new MimimalAccountScript();
        (helperConfig, minimalAccount) = deployMinimal.deployMinimalAccount();
        usdc = new ERC20Mock();
        sendPackedUserOp = new SendPackedUserOp();
    }

    //USDC Mint

    //msg.sender -> minimalAccount
    //approve some amount USDC
    //comes from the entry point

    function testOwnerCanExecuteCommands() public {
        //Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address destination = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        //Act
        vm.prank(minimalAccount.owner());
        minimalAccount.execute(destination, value, functionData);

        //Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), 1);
    }

    /**
     * @notice This tests that if your not the owner or the entry point you shouldn't be able to execute commands
     *
     */
    function testNotOwnerNotEntryPointCannotExecuteCommands() public {
        //Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address destination = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        //Act
        vm.prank(randomUser);

        //Assert
        vm.expectRevert(MinimalAccount.MinimalAccount__NotEntryPointOrOwner.selector);
        minimalAccount.execute(destination, value, functionData);
    }

    function testRecoverSignedOp() public {
        //Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address destination = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        bytes memory executeCallData =
            abi.encodeWithSelector(MinimalAccount.execute.selector, destination, value, functionData);
        PackedUserOperation memory packedUserOp =
            sendPackedUserOp.generateUserOperation(executeCallData, helperConfig.getConfig(), address(minimalAccount));
        bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        //Act
        address actualSigner = ECDSA.recover(userOperationHash.toEthSignedMessageHash(), packedUserOp.signature);
        //Assert
        assertEq(actualSigner, minimalAccount.owner());
    }

    /**
     * @notice This tests that if the signature is invalid the user operation should fail
     * 1. Sign user ops
     * 2. Call validate userops
     * 3. Assert that the reutrn is correct
     */
    function testValidationOfUserOps() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address destination = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        bytes memory executeCallData =
            abi.encodeWithSelector(MinimalAccount.execute.selector, destination, value, functionData);
        PackedUserOperation memory packedUserOp =
            sendPackedUserOp.generateUserOperation(executeCallData, helperConfig.getConfig(), address(minimalAccount));
        bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        uint256 missingAccountFunds = 1e18;

        //Act
        vm.prank(address(helperConfig.getConfig().entryPoint));
        uint256 validationData = minimalAccount.validateUserOp(packedUserOp, userOperationHash, missingAccountFunds);
        //Assert
        assertEq(validationData, 0);
    }

    function testEntryPointCanExecuteCommands() public {
        address destination = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        bytes memory executeCallData =
            abi.encodeWithSelector(MinimalAccount.execute.selector, destination, value, functionData);
        PackedUserOperation memory packedUserOp =
            sendPackedUserOp.generateUserOperation(executeCallData, helperConfig.getConfig(), address(minimalAccount));
        //bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);

        vm.deal(address(minimalAccount), 1e18);

        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = packedUserOp;

        //Act
        vm.prank(randomUser);
        IEntryPoint(helperConfig.getConfig().entryPoint).handleOps(ops, payable(randomUser));

        //assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }
}
