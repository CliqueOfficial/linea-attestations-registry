// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../base/Attestor.sol";

contract ExampleAttestor is Attestor {
    error AlreadyAttested();
    error ModuleFailed(address module);

    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        ModulesRegistry _modulesRegistry,
        address[] memory _modules
    ) Attestor(_masterRegistry, _schemasRegistry, _modulesRegistry, _modules) {}

    function _beforeAttest(
        Attestation memory attestation,
        uint256 value,
        bytes[] memory data
    ) internal override {
        bool owner = $masterRegistry.hasAttestation(
            attestation.attestee,
            attestation.schemaId
        );
        if (owner) revert AlreadyAttested();
        for (uint256 i = 0; i < $modules.length; i++) {
            if (!Module($modules[i]).run(attestation, value, data[i]))
                revert ModuleFailed($modules[i]);
        }
    }

    function _afterAttest(
        Attestation memory attestation,
        uint256 value,
        bytes[] memory data
    ) internal override {}

    function _beforeUpdate(
        UpdateRequest memory _updateRequest,
        uint256 value,
        bytes[] memory data
    ) internal override {}

    function _afterUpdate(
        UpdateRequest memory _updateRequest,
        uint256 value,
        bytes[] memory data
    ) internal override {}
}
