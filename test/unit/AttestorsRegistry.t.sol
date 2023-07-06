// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {MasterRegistry, Attestation, UpdateRequest} from "../../src/MasterRegistry.sol";
import "../../src/AttestorsRegistry.sol";
import {MockAttestor} from "./mocks/MockAttestor.sol";
import {SchemasRegistry, Field} from "../../src/SchemasRegistry.sol";
import {ModulesRegistry} from "../../src/ModulesRegistry.sol";
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
        attestorsRegistry = new AttestorsRegistry();

        mockModule = new MockModule(
            masterRegistry,
            schemasRegistry,
            attestorsRegistry
        );

        modulesRegistry.registerModule(address(mockModule));
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
}
