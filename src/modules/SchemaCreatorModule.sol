// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/Module.sol";

contract SchemaCreatorModule is Module {
    constructor(
        MasterRegistry _masterRegistry,
        SchemaRegistry _schemaRegistry,
        AttestorsRegistry _attestorsRegistry
    ) Module(_masterRegistry, _schemaRegistry, _attestorsRegistry) {}

    function runModule(
        Attestation memory attestation,
        uint256 /*value*/,
        bytes memory /*data*/
    ) external view override returns (bool) {
        _schemaCreator(attestation.attestor, attestation.schemaId);
        return true;
    }

    function _schemaCreator(address attestor, bytes32 schemaId) internal view {
        address schemaCreator = $schemaRegistry.getSchema(schemaId).creator;
        require(
            attestor == schemaCreator,
            "Attestor must be the schema creator"
        );
    }
}
