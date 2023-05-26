// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema} from "./libs/Structs.sol";
import {Attestor} from "./interfaces/Attestor.sol";
import {SchemaRegistry} from "./SchemaRegistry.sol";

contract ValidatorsRegistry {
    SchemaRegistry public $schemaRegistry;
    mapping(address attestor => bool registered) public attestors;
    mapping(address attestor => mapping(bytes32 schemaId => bool registered))
        public attestorSchemas;

    constructor(address _schemaRegistry) {
        $schemaRegistry = SchemaRegistry(_schemaRegistry);
    }

    function registerAttestor(address attestor) external {
        require(
            Attestor(attestor).supportsInterface(type(Attestor).interfaceId),
            "Must implement IAttestor"
        );

        attestors[attestor] = true;
    }

    function addSchema(Schema memory schema) external {
        require(
            msg.sender == address($schemaRegistry),
            "Only the schema registry can register schemas"
        );
        require(
            attestors[schema.attestor],
            "The provided attestor is not registered"
        );
        attestorSchemas[schema.attestor][schema.schemaId] = true;
    }
}
