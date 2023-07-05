// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema, Field} from "./libs/Structs.sol";
import {AttestorsRegistry} from "./AttestorsRegistry.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ISchemasRegistry.sol";

contract SchemasRegistry is ISchemasRegistry, Ownable {
    AttestorsRegistry private $attestorsRegistry;

    mapping(bytes32 schemaId => Schema schema) private $schemas;

    uint256 public schemaCount;

    function setAttestorsRegistry(
        address _attestorsRegistry
    ) external onlyOwner {
        if (_attestorsRegistry == address(0))
            revert InvalidAttestorsRegistryAddress();
        $attestorsRegistry = AttestorsRegistry(_attestorsRegistry);

        emit AttestorsRegistrySet(_attestorsRegistry);
    }

    function registerSchema(Field[] memory schemaFields) external {
        if (address($attestorsRegistry) == address(0))
            revert AttestorsRegistryNotSet();

        bytes32 schemaId = keccak256(
            abi.encodePacked(abi.encode(schemaFields))
        );

        if ($schemas[schemaId].schemaId != bytes32(0))
            revert SchemaAlreadyExists();

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

    function checkSchemaExists(
        Field[] memory schemaFields
    ) external view returns (bytes32) {
        bytes32 schemaId = keccak256(
            abi.encodePacked(abi.encode(schemaFields))
        );

        if ($schemas[schemaId].schemaId != bytes32(0)) {
            return schemaId;
        } else {
            return bytes32(0);
        }
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
