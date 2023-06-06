// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAttestorsRegistry {
    error InvalidAttestorAddress();
    error DoesNotImplementAttestor();
    error OnlySchemasRegistry();
    error AttestorNotRegistered();
    error SchemaAlreadyRegistered();

    event AttestorRegistered(address indexed attestor);
    event SchemaRegistered(address indexed attestor, bytes32 indexed schemaId);
}
