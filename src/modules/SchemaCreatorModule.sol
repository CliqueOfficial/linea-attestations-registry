// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/Module.sol";

error AttesterIsNotSchemaCreator();

// A basic implementation of a module which checks that the attester is the schema creator.
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
    ) external view override returns (Attestation memory, bytes memory) {
        _schemaCreator(attestation.attester, attestation.schemaId);
        return (attestation, bytes(""));
    }

    function _schemaCreator(address attester, bytes32 schemaId) internal view {
        address schemaCreator = $schemasRegistry.getSchema(schemaId).creator;
        if (attester != schemaCreator) revert AttesterIsNotSchemaCreator();
    }
}
