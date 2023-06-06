// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Attestation, UpdateRequest} from "../libs/Structs.sol";

interface IMasterRegistry {
    error OnlyRegisteredAttestors();
    error OnlyAttesteeOrAttestor();
    error InvalidRegistryAddress();
    error InvalidBatchLength();

    event AttestorsRegistrySet(address indexed attestorsRegistry);
    event SchemasRegistrySet(address indexed schemasRegistry);
    event ModulesRegistrySet(address indexed modulesRegistry);
    event AttestationRecorded(Attestation attestation);
    event BatchAttestationRecorded(Attestation[] attestations);
    event AttestationUpdated(UpdateRequest updateRequest);
    event BatchAttestationUpdated(UpdateRequest[] updateRequests);
    event AttestationRevoked(bytes32 indexed attestationId);
    event BatchAttestationRevoked(bytes32[] indexed attestationIds);
}
