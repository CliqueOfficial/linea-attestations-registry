// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SchemaRegistry} from "./SchemaRegistry.sol";
import {AttestorsRegistry} from "./AttestorsRegistry.sol";
import {Attestation} from "./libs/Structs.sol";

error OnlyRegisteredAttestors();

contract MasterRegistry {
    AttestorsRegistry public $attestorsRegistry;
    SchemaRegistry public $schemaRegistry;

    mapping(address attestee => mapping(bytes32 schemaId => Attestation attestation))
        public $attestations;

    modifier onlyAttestor() {
        require(
            $attestorsRegistry.attestors(msg.sender) == true,
            "Must be a registered attestor"
        );
        _;
    }

    function setSchemaRegistry(address _schemaRegistry) external {
        $schemaRegistry = SchemaRegistry(_schemaRegistry);
    }

    // Only the attestor registry can record attestations.
    function attest(Attestation memory _attestation) external onlyAttestor {}

    function attestBatch(
        Attestation[] memory _attestation
    ) external onlyAttestor {}

    function update() external onlyAttestor {}

    function updateBatch() external onlyAttestor {}

    function revoke() external onlyAttestor {}

    function revokeBatch() external onlyAttestor {}

    function getAttestations(
        address attestee,
        bytes32[] memory schemaIds
    ) public view returns (Attestation[] memory) {
        Attestation[] memory attestations = new Attestation[](schemaIds.length);
        for (uint256 i = 0; i < schemaIds.length; i++) {
            attestations[i] = $attestations[attestee][schemaIds[i]];
        }
        return attestations;
    }
}
