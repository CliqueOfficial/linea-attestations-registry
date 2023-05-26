// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from "openzeppelin/utils/cryptography/ECDSA.sol";
import "openzeppelin/interfaces/IERC165.sol";
import {MasterRegistry} from "../MasterRegistry.sol";
import {SchemaRegistry} from "../SchemaRegistry.sol";
import {ModulesRegistry} from "../ModulesRegistry.sol";
import {Module} from "../interfaces/Module.sol";
import {Attestation, AttestationRequest, UpdateRequest} from "../libs/Structs.sol";

abstract contract Attestor is IERC165 {
    MasterRegistry public $masterRegistry;
    SchemaRegistry public $schemaRegistry;
    ModulesRegistry public $modulesRegistry;
    address[] public $modules;

    constructor(
        MasterRegistry _masterRegistry,
        SchemaRegistry _schemaRegistry,
        ModulesRegistry _modulesRegistry,
        address[] memory _modules
    ) {
        require(
            _masterRegistry != MasterRegistry(address(0)),
            "Invalid master registry"
        );
        require(
            _schemaRegistry != SchemaRegistry(address(0)),
            "Invalid master registry"
        );
        require(_modules.length > 0, "Must implement at least one module");
        for (uint256 i = 0; i < _modules.length; i++) {
            bool registered = _modulesRegistry.getModule(_modules[i]);
            require(registered, "Module not registered");
        }

        $masterRegistry = _masterRegistry;
        $schemaRegistry = _schemaRegistry;
        $modulesRegistry = _modulesRegistry;
        $modules = _modules;
    }

    function attest(
        AttestationRequest memory _attestationRequest,
        bytes memory data
    ) external payable {
        Attestation memory attestation = _buildAttestation(_attestationRequest);

        _beforeAttest(attestation, msg.value, data);

        $masterRegistry.attest(attestation);

        _afterAttest(attestation, msg.value, data);
    }

    function attestBatch(
        AttestationRequest[] memory _attestationRequests,
        bytes[] memory data
    ) external payable {
        require(
            _attestationRequests.length == data.length,
            "Must provide the same number of attestations and data"
        );

        uint256 value = msg.value / _attestationRequests.length;

        for (uint256 i = 0; i < _attestationRequests.length; i++) {
            Attestation memory attestation = _buildAttestation(
                _attestationRequests[i]
            );
            require(
                $schemaRegistry.getSchema(attestation.schemaId).attestor ==
                    address(this),
                "This attestation schema does not support this attestor"
            );

            _beforeAttest(attestation, value, data[i]);

            $masterRegistry.attest(attestation);

            _afterAttest(attestation, value, data[i]);
        }
    }

    function delagatedAttest(
        AttestationRequest memory _attestationRequest,
        bytes32 signature,
        bytes memory data
    ) external payable {
        _verifySignature(_attestationRequest, signature);

        Attestation memory attestation = _buildAttestation(_attestationRequest);

        _beforeAttest(attestation, msg.value, data);

        $masterRegistry.attest(attestation);

        _afterAttest(attestation, msg.value, data);
    }

    function delegatedAttestBatch(
        AttestationRequest[] memory _attestationRequests,
        bytes32[] memory signatures,
        bytes[] memory data
    ) external payable {
        require(
            _attestationRequests.length == data.length,
            "Must provide the same number of attestations and data"
        );

        uint256 value = msg.value / _attestationRequests.length;

        for (uint256 i = 0; i < _attestationRequests.length; i++) {
            _verifySignature(_attestationRequests[i], signatures[i]);

            Attestation memory attestation = _buildAttestation(
                _attestationRequests[i]
            );
            require(
                $schemaRegistry.getSchema(attestation.schemaId).attestor ==
                    address(this),
                "This attestation schema does not support this attestor"
            );

            _beforeAttest(attestation, value, data[i]);

            $masterRegistry.attest(attestation);

            _afterAttest(attestation, value, data[i]);
        }
    }

    function update(
        UpdateRequest memory _updateRequest,
        bytes memory data
    ) external payable {
        _beforeUpdate(_updateRequest, msg.value, data);

        $masterRegistry.update(_updateRequest);

        _afterUpdate(_updateRequest, msg.value, data);
    }

    function updateBatch(
        UpdateRequest[] memory _updateRequest,
        bytes[] memory data
    ) external payable {
        require(
            _updateRequest.length == data.length,
            "Must provide the same number of updates and data"
        );
        for (uint256 i = 0; i < _updateRequest.length; i++) {
            _beforeUpdate(_updateRequest[i], msg.value, data[i]);

            $masterRegistry.update(_updateRequest[i]);

            _afterUpdate(_updateRequest[i], msg.value, data[i]);
        }
    }

    function revoke(bytes32 _attestationId) external {
        _revoke(_attestationId);
    }

    function _verifySignature(
        AttestationRequest memory _attestationRequest,
        bytes32 signature
    ) internal {
        bytes32 messageHash = keccak256(
            abi.encode(
                _attestationRequest.schemaId,
                _attestationRequest.attestor,
                _attestationRequest.attestee,
                _attestationRequest.implementation,
                _attestationRequest.implementation,
                _attestationRequest.expirationDate,
                _attestationRequest.attestationData
            )
        );
        require(
            messageHash.toEthSignedMessageHash().recover(signature) ==
                _attestationRequest.attestor,
            "AttestationRequest data not signed by attestor"
        );
    }

    function _beforeAttest(
        Attestation memory _attestation,
        uint256 value,
        bytes memory data
    ) internal virtual;

    function _afterAttest(
        Attestation memory _attestation,
        uint256 value,
        bytes memory data
    ) internal virtual;

    function _beforeUpdate(
        UpdateRequest memory _updateRequest,
        uint256 value,
        bytes memory data
    ) internal virtual;

    function _afterUpdate(
        UpdateRequest memory _updateRequest,
        uint256 value,
        bytes memory data
    ) internal virtual;

    function _revoke(bytes32 /*_attestationId*/) internal virtual {
        // default setting (can be overidden by Attestor creator)
        revert("Only attestee can revoke attestation");
    }

    function _buildAttestation(
        AttestationRequest memory _attestationRequest
    ) internal view returns (Attestation memory) {
        return
            Attestation({
                attestationId: keccak256(abi.encode(_attestationRequest)),
                schemaId: _attestationRequest.schemaId,
                validator: address(this),
                attestor: msg.sender,
                attestee: _attestationRequest.attestee,
                implementation: _attestationRequest.implementation,
                attestedDate: uint64(block.timestamp),
                updatedDate: 0,
                expirationDate: _attestationRequest.expirationDate,
                isPrivate: false,
                revoked: false,
                attestationData: _attestationRequest.attestationData
            });
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public pure virtual override returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(Attestor).interfaceId;
    }
}
