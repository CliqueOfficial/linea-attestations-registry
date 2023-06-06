// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./base/Module.sol";

contract ModulesRegistry {
    error DoesNotImplementModule();
    error InvalidModuleAddress();

    mapping(address module => bool registered) public modules;

    function registerModule(Module module) external {
        if (address(module) == address(0)) revert InvalidModuleAddress();
        if (!Module(module).supportsInterface(type(Module).interfaceId))
            revert DoesNotImplementModule();

        modules[address(module)] = true;
    }

    function getModule(address module) public view returns (bool) {
        return modules[module];
    }
}
