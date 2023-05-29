// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/Module.sol";

error CallerIsNotSchemaCreator();
error InsufficientFee();

contract FeeModule is Module {
    mapping(bytes32 schemaId => uint256 fee) public $creatorFees;
    uint256 public $baseFee = 0;

    constructor(
        MasterRegistry _masterRegistry,
        SchemaRegistry _schemaRegistry,
        AttestorsRegistry _attestorsRegistry
    ) Module(_masterRegistry, _schemaRegistry, _attestorsRegistry) {}

    function setCreatorFee(bytes32 schemaId, uint256 fee) external {
        if (msg.sender != $schemaRegistry.getSchema(schemaId).creator)
            revert CallerIsNotSchemaCreator();
        $creatorFees[schemaId] = fee;
    }

    function run(
        Attestation memory attestation,
        uint256 value,
        bytes memory /*data*/
    ) external view override returns (bool) {
        if (value < $creatorFees[attestation.schemaId])
            revert InsufficientFee();
        return true;
    }
}
