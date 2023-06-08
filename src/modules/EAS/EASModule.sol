// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../base/Module.sol";
import {IEAS, AttestationRequest, AttestationRequestData} from "./IEAS.sol";
import {ISchemaRegistry, ISchemaResolver} from "./ISchemaRegistry.sol";
import {Schema} from "../../libs/Structs.sol";

contract EASModule is Module {
    IEAS $iEAS;
    ISchemaRegistry $iSchemaRegistry;

    event EASAttestationCreation(
        address attestee,
        bytes32 indexed attestationId,
        bytes32 indexed EASAttestationId
    );

    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        AttestorsRegistry _attestorsRegistry,
        IEAS _iEAS,
        ISchemaRegistry _iSchemaResolver
    ) Module(_masterRegistry, _schemasRegistry, _attestorsRegistry) {
        $iEAS = _iEAS;
        $iSchemaRegistry = _iSchemaResolver;
    }

    function run(
        Attestation memory attestation,
        uint256 value,
        bytes memory /*data*/
    ) external override returns (Attestation memory, bytes memory) {
        string memory schema = $schemasRegistry
            .getSchema(attestation.schemaId)
            .schema;

        $iSchemaRegistry.register(schema, ISchemaResolver(address(0)), true);

        AttestationRequestData memory data = AttestationRequestData({
            recipient: attestation.attestee,
            expirationTime: attestation.expirationDate,
            revocable: true,
            refUID: attestation.parentId,
            data: attestation.attestationData,
            value: value
        });

        AttestationRequest memory attestionRequest = AttestationRequest({
            schema: keccak256(
                abi.encodePacked(schema, ISchemaResolver(address(0)), true)
            ),
            data: data
        });

        bytes32 EASAttestationId = $iEAS.attest(attestionRequest);

        emit EASAttestationCreation(
            attestation.attestee,
            attestation.attestationId,
            EASAttestationId
        );

        return (attestation, bytes(""));
    }
}
