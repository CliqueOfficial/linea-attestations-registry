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
        Attestation memory _attestation,
        uint256 _value,
        bytes[] memory _data
    ) internal override returns (Attestation memory) {
        bool owner = $masterRegistry.hasAttestation(
            _attestation.attestee,
            _attestation.schemaId
        );
        if (owner) revert AlreadyAttested();
        Attestation memory finalAttestation;
        for (uint256 i = 0; i < $modules.length; i++) {
            (Attestation memory attestation, ) = Module($modules[i]).run(
                _attestation,
                _value,
                _data[i]
            );
            finalAttestation = attestation;
        }
        return finalAttestation;
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
