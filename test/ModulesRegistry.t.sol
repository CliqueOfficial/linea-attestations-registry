// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {MasterRegistry, Attestation, UpdateRequest} from "../src/MasterRegistry.sol";
import {MockAttestorsRegistry} from "./mocks/MockAttestorsRegistry.sol";
import "../src/ModulesRegistry.sol";
import {MockModule} from "./mocks/MockModule.sol";
import {SchemasRegistry} from "../src/SchemasRegistry.sol";
import {AttestorsRegistry} from "../src/AttestorsRegistry.sol";
import {Module} from "../src/base/Module.sol";

contract ModulesRegistryTest is Test {
    ModulesRegistry internal modulesRegistry;
    MasterRegistry internal masterRegistry;
    SchemasRegistry internal schemasRegistry;
    AttestorsRegistry internal attestorsRegistry;
    MockModule internal mockModule;

    address owner;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        owner = makeAddr("owner");
        vm.deal(owner, 100 ether);

        modulesRegistry = new ModulesRegistry();
        masterRegistry = new MasterRegistry();
        schemasRegistry = new SchemasRegistry();
        attestorsRegistry = new AttestorsRegistry(address(schemasRegistry));
        mockModule = new MockModule(
            masterRegistry,
            schemasRegistry,
            attestorsRegistry
        );
    }

    function test_registerModule() external {
        modulesRegistry.registerModule(address(mockModule));
        assertTrue(modulesRegistry.isRegistered(address(mockModule)));
    }

    function test_registerModule_InvalidModuleAddress() external {
        vm.expectRevert(IModulesRegistry.InvalidModuleAddress.selector);
        modulesRegistry.registerModule(address(0));
    }

    function test_registerModule_DoesNotImplementModule(
        Module module
    ) external {
        vm.assume(address(module) != address(0));
        vm.expectRevert();
        modulesRegistry.registerModule(address(module));
    }
}
