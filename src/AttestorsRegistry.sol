// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema} from "./libs/Structs.sol";
import {Attestor} from "./base/Attestor.sol";
import {SchemaRegistry} from "./SchemaRegistry.sol";

error DoesNotImplementAttestor();
error OnlySchemaRegistry();
error AttestorNotRegistered();

contract AttestorsRegistry {
    SchemaRegistry public $schemaRegistry;

    mapping(address attestor => bool registered) public $attestors;
    mapping(address attestor => mapping(bytes32 schemaId => bool registered))
        public $attestorschemas;

    constructor(address _schemaRegistry) {
        $schemaRegistry = SchemaRegistry(_schemaRegistry);
    }

    function registerAttestor(address attestor) external {
        if (!Attestor(attestor).supportsInterface(type(Attestor).interfaceId))
            revert DoesNotImplementAttestor();

        $attestors[attestor] = true;
    }

    function registerSchema(Schema memory schema) external {
        if (msg.sender != address($schemaRegistry)) revert OnlySchemaRegistry();
        if (!$attestors[schema.attestor]) revert AttestorNotRegistered();

        $attestorschemas[schema.attestor][schema.schemaId] = true;
    }
}
