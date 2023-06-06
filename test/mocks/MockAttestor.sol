// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Attestor} from "../../src/base/Attestor.sol";
import {MasterRegistry} from "../../src/MasterRegistry.sol";
import {SchemasRegistry} from "../../src/SchemasRegistry.sol";
import {ModulesRegistry} from "../../src/ModulesRegistry.sol";
import {Attestation} from "../../src/base/Module.sol";
import {UpdateRequest} from "../../src/libs/Structs.sol";

contract MockAttestor is Attestor {
    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        ModulesRegistry _modulesRegistry,
        address[] memory _modules
    ) Attestor(_masterRegistry, _schemasRegistry, _modulesRegistry, _modules) {}

    function _beforeAttest(
        Attestation memory _attestation,
        uint256 _value,
        bytes[] memory _data
    ) internal override {}

    function _afterAttest(
        Attestation memory _attestation,
        uint256 _value,
        bytes[] memory _data
    ) internal override {}

    function _beforeUpdate(
        UpdateRequest memory _updateRequest,
        uint256 _value,
        bytes[] memory _data
    ) internal override {}

    function _afterUpdate(
        UpdateRequest memory _updateRequest,
        uint256 _value,
        bytes[] memory _data
    ) internal override {}
}
