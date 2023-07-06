// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin/access/Ownable.sol";
import {AttestorsRegistry} from "./AttestorsRegistry.sol";
import {SchemasRegistry} from "./SchemasRegistry.sol";
import {ModulesRegistry} from "./ModulesRegistry.sol";
import {Attestation, UpdateRequest} from "./libs/Structs.sol";
import {Type, Field} from "./libs/Structs.sol";

import "./interfaces/IMasterRegistry.sol";

contract MasterRegistry is IMasterRegistry, Ownable {
    AttestorsRegistry public $attestorsRegistry;
    SchemasRegistry public $schemasRegistry;
    ModulesRegistry public $modulesRegistry;

    mapping(bytes32 attestationId => Attestation attestation)
        private $attestations;
    mapping(address attestee => mapping(bytes32 schemaId => bytes32[]) attestationIds)
        private $attestationIds;

    modifier onlyAttestor() {
        if (!$attestorsRegistry.isRegistered(msg.sender))
            revert OnlyRegisteredAttestors();
        _;
    }

    function setAttestorsRegistry(
        address _attestorsRegistry
    ) external onlyOwner {
        if (_attestorsRegistry == address(0)) revert InvalidRegistryAddress();
        $attestorsRegistry = AttestorsRegistry(_attestorsRegistry);

        emit AttestorsRegistrySet(_attestorsRegistry);
    }

    function setSchemasRegistry(address _schemasRegistry) external onlyOwner {
        if (_schemasRegistry == address(0)) revert InvalidRegistryAddress();
        $schemasRegistry = SchemasRegistry(_schemasRegistry);

        emit SchemasRegistrySet(_schemasRegistry);
    }

    function setModulesRegistry(address _modulesRegistry) external onlyOwner {
        if (_modulesRegistry == address(0)) revert InvalidRegistryAddress();
        $modulesRegistry = ModulesRegistry(_modulesRegistry);

        emit ModulesRegistrySet(_modulesRegistry);
    }

    // Only the attestor registry can record attestations.
    function attest(Attestation memory _attestation) external onlyAttestor {
        $attestations[_attestation.attestationId] = _attestation;
        $attestationIds[_attestation.attestee][_attestation.schemaId].push(
            _attestation.attestationId
        );

        emit AttestationRecorded(_attestation);
    }

    function attestBatch(
        Attestation[] memory _attestations
    ) external onlyAttestor {
        if (_attestations.length == 0) revert InvalidBatchLength();
        uint256 length = _attestations.length;
        for (uint256 i = 0; i < length; ) {
            $attestations[_attestations[i].attestationId] = _attestations[i];
            $attestationIds[_attestations[i].attestee][
                _attestations[i].schemaId
            ].push(_attestations[i].attestationId);

            unchecked {
                ++i;
            }
        }
        emit BatchAttestationRecorded(_attestations);
    }

    function update(UpdateRequest memory _updateRequest) external onlyAttestor {
        Attestation memory attestation = $attestations[
            _updateRequest.attestationId
        ];
        attestation.updatedDate = uint64(block.timestamp);
        attestation.expirationDate = _updateRequest.expirationDate;
        attestation.attestationData = _updateRequest.attestationData;
        $attestations[_updateRequest.attestationId] = attestation;

        emit AttestationUpdated(_updateRequest);
    }

    function updateBatch(
        UpdateRequest[] memory _updateRequests
    ) external onlyAttestor {
        if (_updateRequests.length == 0) revert InvalidBatchLength();

        uint256 length = _updateRequests.length;
        for (uint256 i = 0; i < length; ) {
            Attestation memory attestation = $attestations[
                _updateRequests[i].attestationId
            ];
            attestation.updatedDate = uint64(block.timestamp);
            attestation.expirationDate = _updateRequests[i].expirationDate;
            attestation.attestationData = _updateRequests[i].attestationData;
            $attestations[_updateRequests[i].attestationId] = attestation;

            unchecked {
                ++i;
            }
        }
        emit BatchAttestationUpdated(_updateRequests);
    }

    function revoke(bytes32 attestationId) external {
        address attestee = $attestations[attestationId].attestee;
        address attestor = $attestations[attestationId].attestor;
        if (msg.sender != attestee && msg.sender != attestor)
            revert OnlyAttesteeOrAttestor();

        $attestations[attestationId].revoked = true;
        $attestations[attestationId].attestationData = new bytes[](0);

        emit AttestationRevoked(attestationId);
    }

    function revokeBatch(bytes32[] memory attestationIds) external {
        if (attestationIds.length == 0) revert InvalidBatchLength();
        uint256 length = attestationIds.length;
        for (uint256 i = 0; i < length; ) {
            address attestee = $attestations[attestationIds[i]].attestee;
            address attestor = $attestations[attestationIds[i]].attestor;

            if (msg.sender != attestee && msg.sender != attestor)
                revert OnlyAttesteeOrAttestor();

            $attestations[attestationIds[i]].revoked = true;
            // $attestations[attestationIds[i]].attestationData = "";

            unchecked {
                ++i;
            }
        }
        emit BatchAttestationRevoked(attestationIds);
    }

    function getSchemasRegistry() external view returns (address) {
        return address($schemasRegistry);
    }

    function getModulesRegistry() external view returns (address) {
        return address($modulesRegistry);
    }

    function getAttestorsRegistry() external view returns (address) {
        return address($attestorsRegistry);
    }

    function getAttestation(
        bytes32 attestationId
    ) external view returns (Attestation memory) {
        return $attestations[attestationId];
    }

    function getAttestationValues(
        bytes32 attestationId
    ) external view returns (bytes[] memory) {
        return $attestations[attestationId].attestationData;
    }

    function getAttestationIdsBySchema(
        address attestee,
        bytes32 schema
    ) external view returns (bytes32[] memory) {
        bytes32[] memory attestationIds = $attestationIds[attestee][schema];
        return attestationIds;
    }

    function hasAttestation(
        address attestee,
        bytes32 schema
    ) external view returns (bool) {
        bytes32[] memory attestationIds = $attestationIds[attestee][schema];
        return attestationIds.length > 0;
    }

    function getAttestationSchemaId(
        bytes32 attestationId
    ) external view returns (bytes32) {
        return $attestations[attestationId].schemaId;
    }

    /**
     * @notice This function checks the type of the field and throws an error if the field's type doesn't match the expected type
     * @param schemaId The identifier of the schema from which the fields structure is retrieved
     * @param index The index of the field to check
     * @param expectedType The expected type of the field
     */
    function _validateFieldType(
        bytes32 schemaId,
        uint256 index,
        Type expectedType
    ) internal view {
        // Retrieve the schema fields from the registry using the schema ID
        Field[] memory schemaFields = $schemasRegistry.getSchemaFields(
            schemaId
        );

        if (index >= schemaFields.length) revert InvalidIndex();

        Field memory field = schemaFields[index];
        if (field.t != expectedType) revert FieldTypeMismatch();
    }
}
