// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema} from "../../src/libs/Structs.sol";

error DoesNotImplementAttestor();
error OnlySchemasRegistry();
error AttestorNotRegistered();

contract MockAttestorsRegistry {
    mapping(address attestor => bool registered) public $attestors;
    mapping(address attestor => mapping(bytes32 schemaId => bool registered))
        public $attestorschemas;

    function registerAttestor(address attestor) external {
        $attestors[attestor] = true;
    }

    function registerSchema(Schema memory schema) external {
        $attestorschemas[schema.attestor][schema.schemaId] = true;
    }
}
