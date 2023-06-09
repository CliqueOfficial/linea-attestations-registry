// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {MasterRegistry, Attestation, UpdateRequest} from "../src/MasterRegistry.sol";
import {MockAttestorsRegistry} from "./mocks/MockAttestorsRegistry.sol";
import {Module} from "../src/base/Module.sol";
import "../src/SchemasRegistry.sol";
import {MockAttestor} from "./mocks/MockAttestor.sol";
import {MockModule} from "./mocks/MockModule.sol";
import {AttestorsRegistry} from "../src/AttestorsRegistry.sol";
import {ModulesRegistry} from "../src/ModulesRegistry.sol";
import {Schema} from "../src/libs/Structs.sol";

contract SchemasRegistryTest is Test {
    SchemasRegistry internal schemasRegistry;
    MasterRegistry internal masterRegistry;
    AttestorsRegistry internal attestorsRegistry;
    ModulesRegistry internal modulesRegistry;
    MockAttestorsRegistry internal mockAttestorsRegistry;
    MockAttestor internal mockAttestor;
    MockModule internal mockModule;

    address owner;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        owner = makeAddr("owner");

        vm.startPrank(owner);
        schemasRegistry = new SchemasRegistry();
        mockAttestorsRegistry = new MockAttestorsRegistry();
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                          setAttestorsRegistry TESTS
    //////////////////////////////////////////////////////////////*/

    function test_setAttestorsRegistry(address _attestorsRegistry) external {
        vm.assume((_attestorsRegistry) != address(0));
        vm.prank(owner);
        schemasRegistry.setAttestorsRegistry((_attestorsRegistry));
        assertTrue(
            schemasRegistry.getAttestorsRegistry() == (_attestorsRegistry)
        );
    }

    function test_setAttestorsRegistry_Ownable(
        address _attestorsRegistry
    ) external {
        vm.assume((_attestorsRegistry) != address(0));
        vm.expectRevert("Ownable: caller is not the owner");
        schemasRegistry.setAttestorsRegistry((_attestorsRegistry));
    }

    function test_setAttestorsRegistry_InvalidAttestorsRegistryAddress()
        external
    {
        vm.prank(owner);
        vm.expectRevert(
            ISchemasRegistry.InvalidAttestorsRegistryAddress.selector
        );
        schemasRegistry.setAttestorsRegistry((address(0)));
    }

    /*//////////////////////////////////////////////////////////////
                          registerSchema TESTS
    //////////////////////////////////////////////////////////////*/

    function test_registerSchema(
        string memory schema,
        address attestor
    ) external {
        vm.prank(owner);
        schemasRegistry.setAttestorsRegistry((address(mockAttestorsRegistry)));

        schemasRegistry.registerSchema(attestor, schema, true);
    }

    function test_registerSchema_AttestorsRegistryNotSet(
        string memory schema,
        address attestor
    ) external {
        vm.expectRevert(ISchemasRegistry.AttestorsRegistryNotSet.selector);
        schemasRegistry.registerSchema(attestor, schema, true);
    }

    function test_registerSchema_SchemaAlreadyExists(
        string memory schema,
        address attestor
    ) external {
        vm.prank(owner);
        schemasRegistry.setAttestorsRegistry((address(mockAttestorsRegistry)));

        schemasRegistry.registerSchema(attestor, schema, true);
        vm.expectRevert(ISchemasRegistry.SchemaAlreadyExists.selector);
        schemasRegistry.registerSchema(attestor, schema, true);
    }
}
