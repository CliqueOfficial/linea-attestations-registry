// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/Module.sol";

contract SemaphoreModule is Module {
    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        AttestorsRegistry _attestorsRegistry
    ) Module(_masterRegistry, _schemasRegistry, _attestorsRegistry) {}
}
