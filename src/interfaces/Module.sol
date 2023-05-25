// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin/interfaces/IERC165.sol";
import {MasterRegistry} from "../MasterRegistry.sol";
import {SchemaRegistry} from "../SchemaRegistry.sol";
import {AttestorsRegistry} from "../AttestorsRegistry.sol";
import {Attestation} from "../libs/Structs.sol";

abstract contract Module is IERC165 {
    MasterRegistry public $masterRegistry;
    SchemaRegistry public $schemaRegistry;
    AttestorsRegistry public $attestorsRegistry;

    constructor(
        MasterRegistry _masterRegistry,
        SchemaRegistry _schemaRegistry,
        AttestorsRegistry _attestorsRegistry
    ) {
        require(
            _masterRegistry != MasterRegistry(address(0)),
            "Invalid master registry"
        );
        require(
            _schemaRegistry != SchemaRegistry(address(0)),
            "Invalid master registry"
        );
        require(
            _attestorsRegistry != AttestorsRegistry(address(0)),
            "Invalid master registry"
        );
        $masterRegistry = _masterRegistry;
        $schemaRegistry = _schemaRegistry;
        $attestorsRegistry = _attestorsRegistry;
    }

    function runModule(
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
