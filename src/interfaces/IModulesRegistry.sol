// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Attestation, UpdateRequest} from "../libs/Structs.sol";

interface IModulesRegistry {
    error DoesNotImplementModule();
    error InvalidModuleAddress();

    event ModuleRegistered(address indexed module);
}
