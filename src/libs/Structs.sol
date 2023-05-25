// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct AttestationRequest {
    bytes32 schemaId;
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
    string schema;
}
