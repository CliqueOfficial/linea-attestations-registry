// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {MasterRegistry, Attestation, UpdateRequest} from "../src/MasterRegistry.sol";
import "../src/AttestorsRegistry.sol";
import {MockAttestor} from "./mocks/MockAttestor.sol";
import {SchemasRegistry} from "../src/SchemasRegistry.sol";
import {ModulesRegistry} from "../src/ModulesRegistry.sol";
import {MockModule} from "./mocks/MockModule.sol";

contract AttestorsRegistryTest is Test {
    AttestorsRegistry internal attestorsRegistry;
    MasterRegistry internal masterRegistry;
    MockAttestor internal mockAttestor;
    MockModule internal mockModule;
    SchemasRegistry internal schemasRegistry;
    ModulesRegistry internal modulesRegistry;

    address owner;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        owner = makeAddr("owner");
        vm.deal(owner, 100 ether);

        vm.startPrank(owner);
        masterRegistry = new MasterRegistry();
        schemasRegistry = new SchemasRegistry();
        modulesRegistry = new ModulesRegistry();
        attestorsRegistry = new AttestorsRegistry(address(schemasRegistry));

        mockModule = new MockModule(
            masterRegistry,
            schemasRegistry,
            attestorsRegistry
        );

        modulesRegistry.registerModule(mockModule);
        address[] memory modules = new address[](1);
        modules[0] = address(mockModule);
        mockAttestor = new MockAttestor(
            masterRegistry,
            schemasRegistry,
            modulesRegistry,
            modules
        );
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                        registerAttestor TESTS
    //////////////////////////////////////////////////////////////*/

    function test_registerAttestor() external {
        attestorsRegistry.registerAttestor(address(mockAttestor));
        assertTrue(attestorsRegistry.isRegistered(address(mockAttestor)));
    }

    function test_registerAttestor_InvalidAttestorAddress() external {
        vm.expectRevert(IAttestorsRegistry.InvalidAttestorAddress.selector);
        attestorsRegistry.registerAttestor(address(0));
    }

    function test_registerAttestor_DoesNotImplementAttestor(
        address attestor
    ) external {
        vm.assume(attestor != address(0));
        vm.expectRevert();
        attestorsRegistry.registerAttestor(attestor);
    }

    /*//////////////////////////////////////////////////////////////
                        registerSchema TESTS
    //////////////////////////////////////////////////////////////*/

    function test_registerSchema(Schema memory schema) external {
        schema.attestor = address(mockAttestor);
        attestorsRegistry.registerAttestor(address(mockAttestor));
        vm.prank(address(schemasRegistry));
        attestorsRegistry.registerSchema(schema);
        assertTrue(
            attestorsRegistry.isAttestorSchema(
                address(mockAttestor),
                schema.schemaId
            )
        );
    }

    function test_registerSchema_OnlySchemasRegistry(
        Schema memory schema
    ) external {
        vm.expectRevert(IAttestorsRegistry.OnlySchemasRegistry.selector);
        attestorsRegistry.registerSchema(schema);
    }

    function test_registerSchema_AttestorNotRegistered(
        Schema memory schema
    ) external {
        vm.prank(address(schemasRegistry));
        vm.expectRevert(IAttestorsRegistry.AttestorNotRegistered.selector);
        attestorsRegistry.registerSchema(schema);
    }

    function test_registerSchema_SchemaAlreadyRegistered(
        Schema memory schema
    ) external {
        schema.attestor = address(mockAttestor);
        attestorsRegistry.registerAttestor(address(mockAttestor));
        vm.startPrank(address(schemasRegistry));
        attestorsRegistry.registerSchema(schema);
        vm.expectRevert(IAttestorsRegistry.SchemaAlreadyRegistered.selector);
        attestorsRegistry.registerSchema(schema);
        vm.stopPrank();
    }
}
