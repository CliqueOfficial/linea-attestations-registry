// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema} from "./libs/Structs.sol";
import {Attestor} from "./base/Attestor.sol";
import {SchemasRegistry} from "./SchemasRegistry.sol";

error DoesNotImplementAttestor();
error OnlySchemasRegistry();
error AttestorNotRegistered();

contract AttestorsRegistry {
    SchemasRegistry public $schemasRegistry;

    mapping(address attestor => bool registered) public $attestors;
    mapping(address attestor => mapping(bytes32 schemaId => bool registered))
        public $attestorschemas;

    constructor(address _schemasRegistry) {
        $schemasRegistry = SchemasRegistry(_schemasRegistry);
    }

    function registerAttestor(address attestor) external {
        if (!Attestor(attestor).supportsInterface(type(Attestor).interfaceId))
            revert DoesNotImplementAttestor();

        $attestors[attestor] = true;
    }

    function registerSchema(Schema memory schema) external {
        if (msg.sender != address($schemasRegistry))
            revert OnlySchemasRegistry();
        if (!$attestors[schema.attestor]) revert AttestorNotRegistered();

        $attestorschemas[schema.attestor][schema.schemaId] = true;
    }
}
