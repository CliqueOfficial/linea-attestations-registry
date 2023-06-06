// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./base/Module.sol";
import "./interfaces/IModulesRegistry.sol";

contract ModulesRegistry is IModulesRegistry {
    mapping(address module => bool registered) public modules;

    function registerModule(address module) external {
        if (module == address(0)) revert InvalidModuleAddress();
        if (!Module(module).supportsInterface(type(Module).interfaceId))
            revert DoesNotImplementModule();

        modules[address(module)] = true;

        emit ModuleRegistered(address(module));
    }

    function isRegistered(address module) public view returns (bool) {
        return modules[module];
    }
}
