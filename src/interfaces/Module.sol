// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin/interfaces/IERC165.sol";
import {MasterRegistry} from "../MasterRegistry.sol";
import {SchemaRegistry} from "../SchemaRegistry.sol";
import {ValidatorsRegistry} from "../ValidatorsRegistry.sol";
import {Attestation} from "../libs/Structs.sol";

abstract contract Module is IERC165 {
    MasterRegistry public $masterRegistry;
    SchemaRegistry public $schemaRegistry;
    ValidatorsRegistry public $validatorsRegistry;

    constructor(
        MasterRegistry _masterRegistry,
        SchemaRegistry _schemaRegistry,
        ValidatorsRegistry _validatorsRegistry
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
            _validatorsRegistry != ValidatorsRegistry(address(0)),
            "Invalid master registry"
        );
        $masterRegistry = _masterRegistry;
        $schemaRegistry = _schemaRegistry;
        $validatorsRegistry = _validatorsRegistry;
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
