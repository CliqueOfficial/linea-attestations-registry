// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema} from "../../../src/libs/Structs.sol";

error DoesNotImplementAttestor();
error OnlySchemasRegistry();
error AttestorNotRegistered();

contract MockAttestorsRegistry {
    mapping(address attestor => bool registered) public $attestors;

    function registerAttestor(address attestor) external {
        $attestors[attestor] = true;
    }

    function isRegistered(
        address attestor
    ) public view returns (bool registered) {
        return $attestors[attestor];
    }
}
