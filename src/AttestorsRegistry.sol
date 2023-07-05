// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema} from "./libs/Structs.sol";
import {Attestor} from "./base/Attestor.sol";
import "./interfaces/IAttestorsRegistry.sol";

contract AttestorsRegistry is IAttestorsRegistry {
    mapping(address attestor => bool registered) private $attestors;

    function registerAttestor(address attestor) external {
        if (attestor == address(0)) revert InvalidAttestorAddress();

        if (!Attestor(attestor).supportsInterface(type(Attestor).interfaceId))
            revert DoesNotImplementAttestor();

        $attestors[attestor] = true;
        emit AttestorRegistered(attestor);
    }

    function isRegistered(
        address attestor
    ) public view returns (bool registered) {
        return $attestors[attestor];
    }
}
