// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/Module.sol";

error AttestorIsNotSchemaCreator();

contract SchemaCreatorModule is Module {
    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        AttestorsRegistry _attestorsRegistry
    ) Module(_masterRegistry, _schemasRegistry, _attestorsRegistry) {}

    function run(
        Attestation memory attestation,
        uint256 /*value*/,
        bytes memory /*data*/
    ) external view override returns (bool) {
        _schemaCreator(attestation.attestor, attestation.schemaId);
        return true;
    }

    function _schemaCreator(address attestor, bytes32 schemaId) internal view {
        address schemaCreator = $schemasRegistry.getSchema(schemaId).creator;
        if (attestor != schemaCreator) revert AttestorIsNotSchemaCreator();
    }
}
