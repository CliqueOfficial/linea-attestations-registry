// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SchemaRegistry} from "./SchemaRegistry.sol";
import {ValidatorsRegistry} from "./ValidatorsRegistry.sol";
import {Attestation, UpdateRequest} from "./libs/Structs.sol";

error OnlyRegisteredAttestors();

contract MasterRegistry {
    ValidatorsRegistry public $validatorsRegistry;
    SchemaRegistry public $schemaRegistry;

    mapping(bytes32 attestationId => Attestation attestation)
        public $attestations;
    mapping(address attestee => mapping(bytes32 schemaId => bytes32[]) attestationIds)
        public $attestationIds;

    modifier onlyAttestor() {
        require(
            $validatorsRegistry.attestors(msg.sender) == true,
            "Must be a registered attestor"
        );
        _;
    }

    function setSchemaRegistry(address _schemaRegistry) external {
        $schemaRegistry = SchemaRegistry(_schemaRegistry);
    }

    // Only the attestor registry can record attestations.
    function attest(Attestation memory _attestation) external onlyAttestor {
        $attestations[_attestation.attestationId] = _attestation;
        $attestationIds[_attestation.attestee][_attestation.schemaId].push(
            _attestation.attestationId
        );
    }

    // function attestBatch() external onlyAttestor {}

    function update(UpdateRequest memory _updateRequest) external onlyAttestor {
        Attestation memory attestation = $attestations[
            _updateRequest.attestationId
        ];
        attestation.updatedDate = uint64(block.timestamp);
        attestation.expirationDate = _updateRequest.expirationDate;
        attestation.attestationData = _updateRequest.attestationData;
        $attestations[_updateRequest.attestationId] = attestation;
    }

    // function updateBatch() external onlyAttestor {}

    function revoke(bytes32 attestationId) external {
        address attestee = $attestations[attestationId].attestee;
        address attestor = $attestations[attestationId].attestor;
        bytes32 schemaId = $attestations[attestationId].schemaId;
        require(
            msg.sender == attestee || msg.sender == attestor,
            "Only attestee or attestor can revoke"
        );
        delete $attestations[attestationId];
        delete $attestationIds[attestee][schemaId];
    }

    // function revokeBatch() external onlyAttestor {}

    function hasAttestation(
        address attestee,
        bytes32 schema
    ) external view returns (bool) {
        bytes32[] memory attestationIds = $attestationIds[attestee][schema];
        return attestationIds.length > 0;
    }

    function getAttestationSchemaId(
        bytes32 attestationId
    ) external view returns (bytes32) {
        return $attestations[attestationId].schemaId;
    }

    function getAttesteeAttestationIdsBySchema(
        address attestee,
        bytes32 schemaId
    ) external view returns (bytes32[] memory) {
        return $attestationIds[attestee][schemaId];
    }
}
