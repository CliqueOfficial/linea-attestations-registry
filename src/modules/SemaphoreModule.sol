// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/Module.sol";
import "semaphore/Semaphore.sol";

// A basic implementation of a module implementing the Semaphore protocol.
// Allowing privacy preserving attestations.
contract SemaphoreModule is Semaphore, Module {
    constructor(
        ISemaphoreVerifier _verifier,
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        AttestorsRegistry _attestorsRegistry
    )
        Semaphore(_verifier)
        Module(_masterRegistry, _schemasRegistry, _attestorsRegistry)
    {}

    function run(
        Attestation memory attestation,
        uint256 /*value*/,
        bytes memory data
    ) external override returns (Attestation memory, bytes memory) {
        (
            uint256 groupId,
            uint256 merkleTreeRoot,
            uint256 signal,
            uint256 nullifierHash,
            uint256 externalNullifier,
            uint256[8] memory proof
        ) = abi.decode(
                data,
                (uint256, uint256, uint256, uint256, uint256, uint256[8])
            );

        this.verifyProof(
            groupId,
            merkleTreeRoot,
            signal,
            nullifierHash,
            externalNullifier,
            proof
        );

        return (attestation, bytes(""));
    }
}
