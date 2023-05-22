// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct Attestation {
    uint256 attestationId;
    address attestor;
    address attestee;
    bool isPrivate;
}
