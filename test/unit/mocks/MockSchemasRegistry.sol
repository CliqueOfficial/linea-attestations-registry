// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema, Field} from "../../../src/libs/Structs.sol";
import {AttestorsRegistry} from "../../../src/AttestorsRegistry.sol";
import "../../../src/interfaces/ISchemasRegistry.sol";

contract MockSchemasRegistry is ISchemasRegistry {
    uint256 counter;
    AttestorsRegistry private $attestorsRegistry;

    mapping(bytes32 schemaId => Schema schema) private $schemas;

    uint256 public schemaCount;

    function setAttestorsRegistry(address _attestorsRegistry) external {
        if (_attestorsRegistry == address(0))
            revert InvalidAttestorsRegistryAddress();
        $attestorsRegistry = AttestorsRegistry(_attestorsRegistry);

        emit AttestorsRegistrySet(_attestorsRegistry);
    }

    function registerSchema(Field[] memory schemaFields) external {
        bytes32 schemaId = bytes32("1");

        // Initialize a new Schema without setting schemaFields yet
        Schema storage newSchema = $schemas[schemaId];

        newSchema.schemaId = schemaId;
        newSchema.schemaNumber = ++schemaCount;
        newSchema.creator = msg.sender;

        // Now manually copy schemaFields array into the newSchema
        for (uint i = 0; i < schemaFields.length; i++) {
            newSchema.schemaFields.push(schemaFields[i]);
        }

        emit SchemaRegistered(newSchema);
    }

    function getSchemaFields(
        bytes32 schemaId
    ) external view returns (Field[] memory) {
        return $schemas[schemaId].schemaFields;
    }

    function getSchema(bytes32 schemaId) external view returns (Schema memory) {
        return $schemas[schemaId];
    }

    function getAttestorsRegistry() public view returns (address) {
        return address($attestorsRegistry);
    }
}
