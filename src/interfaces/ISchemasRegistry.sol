// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Attestation, UpdateRequest, Schema} from "../libs/Structs.sol";

interface ISchemasRegistry {
    error AttestorsRegistryNotSet();
    error InvalidAttestorsRegistryAddress();
    error SchemaAlreadyExists();

    event AttestorsRegistrySet(address indexed attestorsRegistry);
    event SchemaRegistered(Schema schema);
}
