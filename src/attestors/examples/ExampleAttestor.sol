// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../interfaces/Attestor.sol";

contract ExampleAttestor is Attestor {
    constructor(
        MasterRegistry _masterRegistry,
        SchemaRegistry _schemaRegistry,
        ModulesRegistry _modulesRegistry,
        address[] memory _modules
    ) Attestor(_masterRegistry, _schemaRegistry, _modulesRegistry, _modules) {}

    function _beforeAttest(
        Attestation memory attestation,
        uint256 value,
        bytes memory data
    ) internal override {
        bool owner = $masterRegistry.hasAttestation(
            attestation.attestee,
            attestation.schemaId
        );
        require(!owner, "Already attested");
        for (uint256 i = 0; i < $modules.length; i++) {
            require(
                Module($modules[i]).runModule(attestation, value, data),
                "Module failed"
            );
        }
    }

    function _afterAttest(
        Attestation memory attestation,
        uint256 value,
        bytes memory data
    ) internal override {}

    function _beforeUpdate(
        UpdateRequest memory _updateRequest,
        uint256 value,
        bytes memory data
    ) internal override {}

    function _afterUpdate(
        UpdateRequest memory _updateRequest,
        uint256 value,
        bytes memory data
    ) internal override {}
}
