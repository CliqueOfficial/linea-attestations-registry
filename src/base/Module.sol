// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin/interfaces/IERC165.sol";
import {MasterRegistry} from "../MasterRegistry.sol";
import {SchemasRegistry} from "../SchemasRegistry.sol";
import {AttestorsRegistry} from "../AttestorsRegistry.sol";
import {Attestation} from "../libs/Structs.sol";

error InvalidMasterRegistry();
error InvalidSchemasRegistry();
error InvalidAttestorsRegistry();

abstract contract Module is IERC165 {
    MasterRegistry public $masterRegistry;
    SchemasRegistry public $schemasRegistry;
    AttestorsRegistry public $attestorsRegistry;

    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        AttestorsRegistry _attestorsRegistry
    ) {
        if (_masterRegistry == MasterRegistry(address(0)))
            revert InvalidMasterRegistry();
        if (_schemasRegistry == SchemasRegistry(address(0)))
            revert InvalidSchemasRegistry();
        if (_attestorsRegistry == AttestorsRegistry(address(0)))
            revert InvalidAttestorsRegistry();

        $masterRegistry = _masterRegistry;
        $schemasRegistry = _schemasRegistry;
        $attestorsRegistry = _attestorsRegistry;
    }

    function run(
        Attestation memory attestation,
        uint256 value,
        bytes memory data
    ) external virtual returns (bool);

    function supportsInterface(
        bytes4 interfaceId
    ) public pure virtual override returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(Module).interfaceId;
    }
}
