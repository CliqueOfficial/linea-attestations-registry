// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct EIP712Signature {
    uint8 v; // The recovery ID.
    bytes32 r; // The x-coordinate of the nonce R.
    bytes32 s; // The signature data.
}

struct UpdateRequest {
    bytes32 attestationId;
    uint64 expirationDate;
    bytes attestationData;
}

struct AttestationRequest {
    bytes32 schemaId;
    address attestor;
    address attestee;
    address implementation;
    uint64 expirationDate;
    bytes attestationData;
}

struct Attestation {
    bytes32 attestationId;
    bytes32 schemaId;
    address attestor;
    address attestee;
    address validator;
    address implementation;
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
