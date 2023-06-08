// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct EIP712Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct UpdateRequest {
    bytes32 attestationId;
    uint64 expirationDate;
    bytes attestationData;
}

struct AttestationRequest {
    bytes32 schemaId;
    bytes32 parentId;
    address attestor;
    address attestee;
    bytes32 implementationId;
    address implementation;
    uint64 expirationDate;
    bytes attestationData;
}

struct Attestation {
    bytes32 attestationId;
    bytes32 schemaId;
    bytes32 parentId;
    address attester;
    address attestee;
    address attestor;
    uint64 attestedDate;
    uint64 updatedDate;
    uint64 expirationDate;
    bool isPrivate;
    bool revoked;
    bytes attestationData;
}

struct Schema {
    bytes32 schemaId;
    uint256 schemaNumber;
    address creator;
    address attestor;
    bool isPrivate;
    bool onChainAttestation;
    string schema;
}
