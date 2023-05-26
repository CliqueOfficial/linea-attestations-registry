// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/Module.sol";

contract FeeModule is Module {
    mapping(bytes32 schemaId => uint256 fee) public $creatorFees;
    uint256 public $baseFee = 0;

    constructor(
        MasterRegistry _masterRegistry,
        SchemaRegistry _schemaRegistry,
        ValidatorsRegistry _validatorsRegistry
    ) Module(_masterRegistry, _schemaRegistry, _validatorsRegistry) {}

    function setCreatorFee(bytes32 schemaId, uint256 fee) external {
        require(
            msg.sender == $schemaRegistry.getSchema(schemaId).creator,
            "Must be the schema creator"
        );
        $creatorFees[schemaId] = fee;
    }

    function runModule(
        Attestation memory attestation,
        uint256 value,
        bytes memory /*data*/
    ) external view override returns (bool) {
        require(
            value >= $creatorFees[attestation.schemaId],
            "Insufficient fee"
        );
        return true;
    }
}
