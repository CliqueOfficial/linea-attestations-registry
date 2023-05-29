// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin/access/Ownable.sol";
import {AttestorsRegistry} from "./AttestorsRegistry.sol";
import {Attestation, UpdateRequest} from "./libs/Structs.sol";

contract MasterRegistry is Ownable {
    error OnlyRegisteredAttestors();
    error OnlyAttesteeOrAttestor();
    error InvalidAttestorRegistry();
    error InvalidBatchLength();

    AttestorsRegistry public $attestorsRegistry;

    mapping(bytes32 attestationId => Attestation attestation)
        private $attestations;
    mapping(address attestee => mapping(bytes32 schemaId => bytes32[]) attestationIds)
        private $attestationIds;

    modifier onlyAttestor() {
        if (!$attestorsRegistry.$attestors(msg.sender))
            revert OnlyRegisteredAttestors();
        _;
    }

    function setAttestorRegistry(
        address _attestorsRegistry
    ) external onlyOwner {
        if (_attestorsRegistry == address(0)) revert InvalidAttestorRegistry();
        $attestorsRegistry = AttestorsRegistry(_attestorsRegistry);
    }

    // Only the attestor registry can record attestations.
    function attest(Attestation memory _attestation) external onlyAttestor {
        $attestations[_attestation.attestationId] = _attestation;
        $attestationIds[_attestation.attestee][_attestation.schemaId].push(
            _attestation.attestationId
        );
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
    }

    function update(UpdateRequest memory _updateRequest) external onlyAttestor {
        Attestation memory attestation = $attestations[
            _updateRequest.attestationId
        ];
        attestation.updatedDate = uint64(block.timestamp);
        attestation.expirationDate = _updateRequest.expirationDate;
        attestation.attestationData = _updateRequest.attestationData;
        $attestations[_updateRequest.attestationId] = attestation;
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
    }

    function revoke(bytes32 attestationId) external {
        address attestee = $attestations[attestationId].attestee;
        address attestor = $attestations[attestationId].attestor;
        if (msg.sender != attestee && msg.sender != attestor)
            revert OnlyAttesteeOrAttestor();

        $attestations[attestationId].revoked = true;
        $attestations[attestationId].attestationData = "";
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
            $attestations[attestationIds[i]].attestationData = "";

            unchecked {
                ++i;
            }
        }
    }

    function getAttestation(
        bytes32 attestationId
    ) external view returns (Attestation memory) {
        return $attestations[attestationId];
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
}
