// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/Module.sol";

contract ModulesRegistry {
    mapping(address module => bool registered) public modules;

    function registerModule(Module module) external {
        require(
            Module(module).supportsInterface(type(Module).interfaceId),
            "Must implement Module interface"
        );

        modules[address(module)] = true;
    }

    function getModule(address module) public view returns (bool) {
        return modules[module];
    }
}
