// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../src/base/Module.sol";

contract MockModule is Module {
    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        AttestorsRegistry _attestorsRegistry
    ) Module(_masterRegistry, _schemasRegistry, _attestorsRegistry) {}

    function run(
        Attestation memory /*attestation*/,
        uint256 /*value*/,
        bytes memory /*data*/
    ) external view override returns (bool) {
        return true;
    }
}
