// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema} from "./libs/Structs.sol";
import {Attestor} from "./base/Attestor.sol";
import {SchemasRegistry} from "./SchemasRegistry.sol";

contract AttestorsRegistry {
    error InvalidAttestorAddress();
    error DoesNotImplementAttestor();
    error OnlySchemasRegistry();
    error AttestorNotRegistered();
    error SchemaAlreadyRegistered();

    SchemasRegistry public $schemasRegistry;

    mapping(address attestor => bool registered) private $attestors;
    mapping(address attestor => mapping(bytes32 schemaId => bool registered))
        public $attestorSchemas;

    constructor(address _schemasRegistry) {
        $schemasRegistry = SchemasRegistry(_schemasRegistry);
    }

    function registerAttestor(address attestor) external {
        if (attestor == address(0)) revert InvalidAttestorAddress();

        if (!Attestor(attestor).supportsInterface(type(Attestor).interfaceId))
            revert DoesNotImplementAttestor();

        $attestors[attestor] = true;
    }

    function registerSchema(Schema memory schema) external {
        if (msg.sender != address($schemasRegistry))
            revert OnlySchemasRegistry();
        if (!$attestors[schema.attestor]) revert AttestorNotRegistered();
        if ($attestorSchemas[schema.attestor][schema.schemaId])
            revert SchemaAlreadyRegistered();

        $attestorSchemas[schema.attestor][schema.schemaId] = true;
    }

    function isRegistered(
        address attestor
    ) public view returns (bool registered) {
        return $attestors[attestor];
    }

    function isAttestorSchema(
        address attestor,
        bytes32 schemaId
    ) public view returns (bool registered) {
        return $attestorSchemas[attestor][schemaId];
    }
}
