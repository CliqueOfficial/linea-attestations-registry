// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema} from "./libs/Structs.sol";
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

    function registerSchema(
        address attestor,
        string memory schema,
        bool onChain
    ) external {
        if (address($attestorsRegistry) == address(0))
            revert AttestorsRegistryNotSet();

        Schema memory newSchema = Schema({
            schemaId: keccak256(abi.encodePacked(msg.sender, attestor, schema)),
            schemaNumber: ++schemaCount,
            creator: msg.sender,
            attestor: attestor,
            isPrivate: false,
            onChainAttestation: onChain,
            schema: schema
        });

        if ($schemas[newSchema.schemaId].schemaId != bytes32(0))
            revert SchemaAlreadyExists();

        $schemas[newSchema.schemaId] = newSchema;

        $attestorsRegistry.registerSchema(newSchema);

        emit SchemaRegistered(newSchema);
    }

    function getSchema(bytes32 schemaId) external view returns (Schema memory) {
        return $schemas[schemaId];
    }

    function getAttestorsRegistry() public view returns (address) {
        return address($attestorsRegistry);
    }
}
