// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema} from "./libs/Structs.sol";
import {AttestorsRegistry} from "./AttestorsRegistry.sol";

contract SchemaRegistry {
    AttestorsRegistry public $attestorsRegistry;
    mapping(bytes32 schemaId => Schema schema) public $schemas;

    uint256 public schemaCount;

    function getSchema(bytes32 schemaId) external view returns (Schema memory) {
        return $schemas[schemaId];
    }

    function registerSchema(address attestor, string memory schema) external {
        Schema memory newSchema = Schema({
            schemaId: keccak256(abi.encodePacked(msg.sender, attestor, schema)),
            schemaNumber: ++schemaCount,
            creator: msg.sender,
            attestor: attestor,
            isPrivate: false,
            schema: schema
        });

        require(
            $schemas[newSchema.schemaId].schemaId != bytes32(0),
            "Schema already exists"
        );

        $schemas[newSchema.schemaId] = newSchema;

        AttestorsRegistry(address($attestorsRegistry)).addSchema(newSchema);
    }
}
