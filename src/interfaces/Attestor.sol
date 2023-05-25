// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin/interfaces/IERC165.sol";
import {MasterRegistry} from "../MasterRegistry.sol";
import {SchemaRegistry} from "../SchemaRegistry.sol";
import {ModulesRegistry} from "../ModulesRegistry.sol";
import {Module} from "../interfaces/Module.sol";
import {Attestation, AttestationRequest} from "../libs/Structs.sol";

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

    function _buildAttestation(
        AttestationRequest memory _attestationRequest
    ) internal view returns (Attestation memory) {
        return
            Attestation({
                attestationId: keccak256(abi.encode(_attestationRequest)),
                schemaId: _attestationRequest.schemaId,
                attestor: address(this),
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
