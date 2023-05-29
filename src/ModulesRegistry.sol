// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./base/Module.sol";

error DoesNotImplementModule();

contract ModulesRegistry {
    mapping(address module => bool registered) public modules;

    function registerModule(Module module) external {
        if (!Module(module).supportsInterface(type(Module).interfaceId))
            revert DoesNotImplementModule();

        modules[address(module)] = true;
    }

    function getModule(address module) public view returns (bool) {
        return modules[module];
    }
}
