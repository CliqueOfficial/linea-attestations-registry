// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin/utils/cryptography/ECDSA.sol";
import {MasterRegistry} from "../MasterRegistry.sol";
import {SchemasRegistry} from "../SchemasRegistry.sol";
import {ModulesRegistry} from "../ModulesRegistry.sol";
import {Module} from "../base/Module.sol";
import {IERC165} from "openzeppelin/interfaces/IERC165.sol";
import {Attestation, AttestationRequest, UpdateRequest, EIP712Signature} from "../libs/Structs.sol";

abstract contract Attestor is IERC165 {
    using ECDSA for bytes32;

    MasterRegistry public $masterRegistry;
    SchemasRegistry public $schemasRegistry;
    ModulesRegistry public $modulesRegistry;
    address[] public $modules;

    error InvalidMasterRegistry();
    error InvalidSchemasRegistry();
    error NoModulesProvided();
    error ArrayLengthMismatch();
    error UnsupportedSchema();
    error InvalidSignature();
    error ModuleNotRegistered(address module);

    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        ModulesRegistry _modulesRegistry,
        address[] memory _modules
    ) {
        if (_masterRegistry == MasterRegistry(address(0)))
            revert InvalidMasterRegistry();
        if (_schemasRegistry == SchemasRegistry(address(0)))
            revert InvalidSchemasRegistry();
        if (_modules.length == 0) revert NoModulesProvided();

        for (uint256 i = 0; i < _modules.length; i++) {
            bool registered = _modulesRegistry.isRegistered(_modules[i]);
            if (!registered) revert ModuleNotRegistered(_modules[i]);
        }

        $masterRegistry = _masterRegistry;
        $schemasRegistry = _schemasRegistry;
        $modulesRegistry = _modulesRegistry;
        $modules = _modules;
    }

    // Attests attestations to the master registry.
    function attest(
        AttestationRequest memory _attestationRequest,
        bytes[] memory _data
    ) external payable {
        Attestation memory attestation = _buildAttestation(_attestationRequest);

        _verifyBytesLength(_data);

        _beforeAttest(attestation, msg.value, _data);

        $masterRegistry.attest(attestation);

        _afterAttest(attestation, msg.value, _data);
    }

    // Attests a batch of attestations to the master registry.
    function attestBatch(
        AttestationRequest[] memory _attestationRequests,
        bytes[][] memory _data
    ) external payable {
        if (_attestationRequests.length != _data.length)
            revert ArrayLengthMismatch();

        uint256 value = msg.value / _attestationRequests.length;

        for (uint256 i = 0; i < _attestationRequests.length; i++) {
            Attestation memory attestation = _buildAttestation(
                _attestationRequests[i]
            );

            _verifyBytesLength(_data[i]);

            attestation = _beforeAttest(attestation, value, _data[i]);

            $masterRegistry.attest(attestation);

            _afterAttest(attestation, value, _data[i]);
        }
    }

    // Delegated attesting to the master registry through signature verification.
    function delagatedAttest(
        AttestationRequest memory _attestationRequest,
        EIP712Signature memory _signature,
        bytes[] memory _data
    ) external payable {
        _verifyDelegatedAttest(_attestationRequest, _signature);

        Attestation memory attestation = _buildAttestation(_attestationRequest);

        _beforeAttest(attestation, msg.value, _data);

        $masterRegistry.attest(attestation);

        _afterAttest(attestation, msg.value, _data);
    }

    // Delegated batch attesting to the master registry through signature verifications.
    function delegatedAttestBatch(
        AttestationRequest[] memory _attestationRequests,
        EIP712Signature[] memory _signatures,
        bytes[][] memory _data
    ) external payable {
        if (_attestationRequests.length != _data.length)
            revert ArrayLengthMismatch();

        uint256 value = msg.value / _attestationRequests.length;

        for (uint256 i = 0; i < _attestationRequests.length; i++) {
            _verifyDelegatedAttest(_attestationRequests[i], _signatures[i]);

            Attestation memory attestation = _buildAttestation(
                _attestationRequests[i]
            );

            _beforeAttest(attestation, value, _data[i]);

            $masterRegistry.attest(attestation);

            _afterAttest(attestation, value, _data[i]);
        }
    }

    // Updates an attestation in the master registry.
    function update(
        UpdateRequest memory _updateRequest,
        bytes[] memory _data
    ) external payable {
        _verifyBytesLength(_data);

        _beforeUpdate(_updateRequest, msg.value, _data);

        $masterRegistry.update(_updateRequest);

        _afterUpdate(_updateRequest, msg.value, _data);
    }

    // Delegated updating of an attestation through signature verification.
    function delegatedUpdate(
        UpdateRequest memory _updateRequest,
        EIP712Signature memory _signature,
        bytes[] memory _data
    ) external payable {
        _verifyDelegatedUpdate(_updateRequest, _signature);

        _verifyBytesLength(_data);

        _beforeUpdate(_updateRequest, msg.value, _data);

        $masterRegistry.update(_updateRequest);

        _afterUpdate(_updateRequest, msg.value, _data);
    }

    // Updates a batch of attestations in the master registry.
    function updateBatch(
        UpdateRequest[] memory _updateRequest,
        bytes[][] memory _data
    ) external payable {
        if (_updateRequest.length == _data.length) revert ArrayLengthMismatch();

        for (uint256 i = 0; i < _updateRequest.length; i++) {
            _verifyBytesLength(_data[i]);

            _beforeUpdate(_updateRequest[i], msg.value, _data[i]);

            $masterRegistry.update(_updateRequest[i]);

            _afterUpdate(_updateRequest[i], msg.value, _data[i]);
        }
    }

    // Delegated batch updating of attestations through signature verification.
    function delegatedUpdateBatch(
        UpdateRequest[] memory _updateRequests,
        EIP712Signature[] memory _signatures,
        bytes[][] memory _data
    ) external payable {
        if (_updateRequests.length == _data.length)
            revert ArrayLengthMismatch();

        for (uint256 i = 0; i < _updateRequests.length; i++) {
            _verifyBytesLength(_data[i]);

            _verifyDelegatedUpdate(_updateRequests[i], _signatures[i]);

            _beforeUpdate(_updateRequests[i], msg.value, _data[i]);

            $masterRegistry.update(_updateRequests[i]);

            _afterUpdate(_updateRequests[i], msg.value, _data[i]);
        }
    }

    // Revokes an attestation in the master registry.
    function revoke(bytes32 _attestationId) external {
        _revoke(_attestationId);
    }

    function _verifyDelegatedAttest(
        AttestationRequest memory _attestationRequest,
        EIP712Signature memory _signature
    ) internal pure {
        bytes32 messageHash = keccak256(abi.encode(_attestationRequest));

        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(
            messageHash
        );
        _verifySignature(
            _attestationRequest.attestor,
            ethSignedMessageHash,
            _signature.v,
            _signature.r,
            _signature.s
        );
    }

    function _verifyDelegatedUpdate(
        UpdateRequest memory _updateRequest,
        EIP712Signature memory _signature
    ) internal view {
        bytes32 messageHash = keccak256(abi.encode(_updateRequest));

        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(
            messageHash
        );

        address attestor = $masterRegistry
            .getAttestation(_updateRequest.attestationId)
            .attestor;

        _verifySignature(
            attestor,
            ethSignedMessageHash,
            _signature.v,
            _signature.r,
            _signature.s
        );
    }

    function _verifySignature(
        address attestor,
        bytes32 ethSignedMessageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure {
        address signer = ECDSA.recover(ethSignedMessageHash, v, r, s);
        if (signer != attestor) revert InvalidSignature();
    }

    function _verifyBytesLength(bytes[] memory bytesArray) internal view {
        if (bytesArray.length != $modules.length) revert ArrayLengthMismatch();
    }

    function _beforeAttest(
        Attestation memory _attestation,
        uint256 _value,
        bytes[] memory _data
    ) internal virtual returns (Attestation memory);

    function _afterAttest(
        Attestation memory _attestation,
        uint256 _value,
        bytes[] memory _data
    ) internal virtual;

    function _beforeUpdate(
        UpdateRequest memory _updateRequest,
        uint256 _value,
        bytes[] memory _data
    ) internal virtual;

    function _afterUpdate(
        UpdateRequest memory _updateRequest,
        uint256 _value,
        bytes[] memory _data
    ) internal virtual;

    function _revoke(bytes32 /*_attestationId*/) internal virtual {
        // default setting (can be overidden by Attestor creator)
        revert();
    }

    function _buildAttestation(
        AttestationRequest memory _attestationRequest
    ) internal view returns (Attestation memory) {
        Attestation memory attestation = Attestation({
            attestationId: keccak256(abi.encode(_attestationRequest)),
            schemaId: _attestationRequest.schemaId,
            parentId: _attestationRequest.parentId,
            attestor: address(this),
            attester: msg.sender,
            attestee: _attestationRequest.attestee,
            attestedDate: uint64(block.timestamp),
            updatedDate: 0,
            expirationDate: _attestationRequest.expirationDate,
            isPrivate: false,
            revoked: false,
            attestationData: _attestationRequest.attestationData
        });

        return attestation;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public pure virtual override returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(Attestor).interfaceId;
    }
}
