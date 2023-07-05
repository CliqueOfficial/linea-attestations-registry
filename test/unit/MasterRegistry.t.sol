// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import "../../src/MasterRegistry.sol";
import {MockAttestorsRegistry} from "./mocks/MockAttestorsRegistry.sol";
import {MockSchemasRegistry} from "./mocks/MockSchemasRegistry.sol";

contract MasterRegistryTest is Test {
    MasterRegistry internal masterRegistry;
    MockAttestorsRegistry internal mockAttestorsRegistry;
    MockSchemasRegistry internal mockSchemasRegistry;

    address owner;
    address attestee_1;
    address attestee_2;
    address attestor_1;
    address attestor_2;
    address attestorsRegsitry;

    Attestation attestation_1;
    Attestation attestation_2;
    UpdateRequest updateRequest_1;
    UpdateRequest updateRequest_2;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        owner = makeAddr("owner");
        attestor_1 = makeAddr("attestor_1");
        attestor_2 = makeAddr("attestor_2");
        attestorsRegsitry = makeAddr("attestorsRegsitry");
        vm.deal(owner, 100 ether);
        vm.deal(attestor_1, 100 ether);
        vm.deal(attestor_2, 100 ether);

        vm.startPrank(owner);
        masterRegistry = new MasterRegistry();
        mockAttestorsRegistry = new MockAttestorsRegistry();
        vm.stopPrank();

        mockSchemasRegistry = new MockSchemasRegistry();

        bytes[] memory data = new bytes[](6);
        data[0] = bytes(abi.encode(50));
        data[1] = bytes(abi.encode(-100));
        data[2] = bytes(abi.encode(true));
        data[3] = bytes(abi.encode(address(5)));
        data[4] = bytes(abi.encode("test"));
        data[5] = bytes(abi.encode(bytes32("test")));

        attestation_1 = Attestation({
            attestationId: bytes32("1"),
            schemaId: bytes32("1"),
            parentId: bytes32(0),
            attester: owner,
            attestee: attestee_1,
            attestor: attestor_1,
            attestedDate: 0,
            updatedDate: 0,
            expirationDate: 0,
            isPrivate: false,
            revoked: false,
            attestationData: data
        });

        attestation_2 = Attestation({
            attestationId: bytes32("2"),
            schemaId: bytes32("1"),
            parentId: bytes32(0),
            attester: owner,
            attestee: attestee_2,
            attestor: attestor_1,
            attestedDate: 0,
            updatedDate: 0,
            expirationDate: 0,
            isPrivate: false,
            revoked: false,
            attestationData: data
        });

        updateRequest_1 = UpdateRequest({
            attestationId: bytes32("1"),
            expirationDate: 0,
            attestationData: data
        });

        updateRequest_2 = UpdateRequest({
            attestationId: bytes32("2"),
            expirationDate: 0,
            attestationData: data
        });
    }

    function test_Ownerhship() external {
        assertEq(masterRegistry.owner(), owner);
    }

    /*//////////////////////////////////////////////////////////////
                       setAttestorsRegistry TESTS
    //////////////////////////////////////////////////////////////*/

    function test_setAttestorsRegistry() external {
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(attestorsRegsitry);
        assertEq(
            address(masterRegistry.$attestorsRegistry()),
            attestorsRegsitry
        );
    }

    function test_setAttestorsRegistry_Ownable() external {
        vm.expectRevert("Ownable: caller is not the owner");
        masterRegistry.setAttestorsRegistry(attestorsRegsitry);
    }

    function test_setAttestorsRegistry_InvalidRegistryAddress() external {
        vm.startPrank(owner);
        vm.expectRevert(IMasterRegistry.InvalidRegistryAddress.selector);
        masterRegistry.setAttestorsRegistry(address(0));
    }

    /*//////////////////////////////////////////////////////////////
                               attest TESTS
    //////////////////////////////////////////////////////////////*/

    function test_attest() external {
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        vm.prank(attestor_1);
        masterRegistry.attest(attestation_1);

        Attestation memory attestationFromRegistry = masterRegistry
            .getAttestation(attestation_1.attestationId);

        assertEq(
            attestationFromRegistry.attestationId,
            attestation_1.attestationId
        );
        assertEq(attestationFromRegistry.schemaId, attestation_1.schemaId);
        assertEq(attestationFromRegistry.attester, attestation_1.attester);
        assertEq(attestationFromRegistry.attestee, attestation_1.attestee);
        assertEq(attestationFromRegistry.attestor, attestor_1);
        assertEq(
            attestationFromRegistry.attestedDate,
            attestation_1.attestedDate
        );
        assertEq(
            attestationFromRegistry.updatedDate,
            attestation_1.updatedDate
        );
        assertEq(
            attestationFromRegistry.expirationDate,
            attestation_1.expirationDate
        );
        assertEq(attestationFromRegistry.isPrivate, attestation_1.isPrivate);
        assertEq(attestationFromRegistry.revoked, attestation_1.revoked);
        assertEq(
            attestationFromRegistry.attestationData[0],
            attestation_1.attestationData[0]
        );

        bytes32[] memory attestationIds = masterRegistry
            .getAttestationIdsBySchema(
                attestation_1.attestee,
                attestation_1.schemaId
            );
        assertEq(attestationIds.length, 1);
        assertEq(attestationIds[0], attestation_1.attestationId);
    }

    function test_attest_OnlyRegisteredAttestors(
        Attestation memory attestation
    ) external {
        vm.assume(attestation.attestationData.length == 10);
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        attestation.attestor = attestor_1;

        vm.expectRevert(IMasterRegistry.OnlyRegisteredAttestors.selector);
        masterRegistry.attest(attestation);
    }

    /*//////////////////////////////////////////////////////////////
                               attestBatch TESTS
    //////////////////////////////////////////////////////////////*/

    function test_attestBatch() external {
        Attestation[] memory attestations = new Attestation[](2);
        attestations[0] = attestation_1;
        attestations[1] = attestation_2;

        vm.assume(attestations.length > 0);
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        for (uint i = 0; i < attestations.length; i++) {
            attestations[i].attestationId = bytes32(i);
        }

        vm.prank(attestor_1);
        masterRegistry.attestBatch(attestations);

        for (uint i = 0; i < attestations.length; i++) {
            Attestation memory attestationFromRegistry = masterRegistry
                .getAttestation(attestations[i].attestationId);

            assertEq(
                attestationFromRegistry.attestationId,
                attestations[i].attestationId
            );
            assertEq(
                attestationFromRegistry.schemaId,
                attestations[i].schemaId
            );
            assertEq(
                attestationFromRegistry.attester,
                attestations[i].attester
            );
            assertEq(
                attestationFromRegistry.attestee,
                attestations[i].attestee
            );
            assertEq(
                attestationFromRegistry.attestor,
                attestations[i].attestor
            );
            assertEq(
                attestationFromRegistry.attestedDate,
                attestations[i].attestedDate
            );
            assertEq(
                attestationFromRegistry.updatedDate,
                attestations[i].updatedDate
            );
            assertEq(
                attestationFromRegistry.expirationDate,
                attestations[i].expirationDate
            );
            assertEq(
                attestationFromRegistry.isPrivate,
                attestations[i].isPrivate
            );
            assertEq(attestationFromRegistry.revoked, attestations[i].revoked);
            assertEq(
                attestationFromRegistry.attestationData[0],
                attestations[i].attestationData[0]
            );
        }
    }

    function test_attestBatch_InvalidBatchLength() external {
        Attestation[] memory attestations = new Attestation[](0);

        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        vm.expectRevert(IMasterRegistry.InvalidBatchLength.selector);
        vm.prank(attestor_1);
        masterRegistry.attestBatch(attestations);
    }

    function test_attestBatch_OnlyRegisteredAttestors() external {
        Attestation[] memory attestations = new Attestation[](2);
        attestations[0] = attestation_1;
        attestations[1] = attestation_2;

        vm.assume(attestations.length > 0);
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        vm.expectRevert(IMasterRegistry.OnlyRegisteredAttestors.selector);
        masterRegistry.attestBatch(attestations);
    }

    // /*//////////////////////////////////////////////////////////////
    //                            update TESTS
    // //////////////////////////////////////////////////////////////*/

    function test_update(
        bytes32 attestationId,
        uint64 expirationDate,
        bytes[] memory attestationData
    ) external {
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        UpdateRequest memory updateRequest = UpdateRequest(
            attestationId,
            expirationDate,
            attestationData
        );

        vm.prank(attestor_1);
        masterRegistry.update(updateRequest);

        Attestation memory attestationFromRegistry = masterRegistry
            .getAttestation(attestationId);

        assertEq(attestationFromRegistry.expirationDate, expirationDate);
        assertEq(
            attestationFromRegistry.attestationData[0],
            attestationData[0]
        );
    }

    function test_update_OnlyRegisteredAttestors(
        bytes32 attestationId,
        uint64 expirationDate,
        bytes[] memory attestationData
    ) external {
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        UpdateRequest memory updateRequest = UpdateRequest(
            attestationId,
            expirationDate,
            attestationData
        );

        vm.expectRevert(IMasterRegistry.OnlyRegisteredAttestors.selector);
        masterRegistry.update(updateRequest);
    }

    // /*//////////////////////////////////////////////////////////////
    //                            update TESTS
    // //////////////////////////////////////////////////////////////*/

    function test_updateBatch() external {
        UpdateRequest[] memory updateRequests = new UpdateRequest[](2);
        updateRequests[0] = updateRequest_1;
        updateRequests[1] = updateRequest_2;

        vm.assume(updateRequests.length > 0);
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        for (uint i = 0; i < updateRequests.length; i++) {
            updateRequests[i].attestationId = bytes32(i);
        }

        vm.prank(attestor_1);
        masterRegistry.updateBatch(updateRequests);

        for (uint i = 0; i < updateRequests.length; i++) {
            Attestation memory attestationFromRegistry = masterRegistry
                .getAttestation(updateRequests[i].attestationId);

            assertEq(
                attestationFromRegistry.expirationDate,
                updateRequests[i].expirationDate
            );
            assertEq(
                attestationFromRegistry.attestationData[0],
                updateRequests[i].attestationData[0]
            );
        }
    }

    function test_updateBatch_InvalidBatchLength() external {
        UpdateRequest[] memory updateRequests = new UpdateRequest[](2);
        updateRequests[0] = updateRequest_1;
        updateRequests[1] = updateRequest_2;

        vm.assume(updateRequests.length > 0);
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        vm.expectRevert(IMasterRegistry.InvalidBatchLength.selector);
        UpdateRequest[] memory invalidUpdateRequests = new UpdateRequest[](0);

        vm.prank(attestor_1);
        masterRegistry.updateBatch(invalidUpdateRequests);
    }

    function test_updateBatch_OnlyRegisteredAttestors() external {
        UpdateRequest[] memory updateRequests = new UpdateRequest[](2);
        updateRequests[0] = updateRequest_1;
        updateRequests[1] = updateRequest_2;

        vm.assume(updateRequests.length > 0);
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        vm.expectRevert(IMasterRegistry.OnlyRegisteredAttestors.selector);
        masterRegistry.updateBatch(updateRequests);
    }

    /*//////////////////////////////////////////////////////////////
                               revoke TESTS
    //////////////////////////////////////////////////////////////*/

    function test_revoke() external {
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        vm.startPrank(attestor_1);
        masterRegistry.attest(attestation_1);
        masterRegistry.attest(attestation_2);

        masterRegistry.revoke(attestation_1.attestationId);
        vm.stopPrank();

        vm.prank(attestee_2);
        masterRegistry.revoke(attestation_2.attestationId);

        assertEq(
            masterRegistry.getAttestation(attestation_1.attestationId).revoked,
            true
        );
        assertEq(
            masterRegistry.getAttestation(attestation_2.attestationId).revoked,
            true
        );
        // assertEq(
        //     masterRegistry
        //         .getAttestation(attestation_1.attestationId)
        //         .attestationData,
        //     ""
        // );
        // assertEq(
        //     masterRegistry
        //         .getAttestation(attestation_2.attestationId)
        //         .attestationData,
        //     ""
        // );
    }

    function test_revoke_OnlyAttesteeOrAttestor() external {
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        vm.startPrank(attestor_1);
        masterRegistry.attest(attestation_1);
        masterRegistry.attest(attestation_2);
        vm.stopPrank();

        vm.prank(attestor_2);
        vm.expectRevert(IMasterRegistry.OnlyAttesteeOrAttestor.selector);
        masterRegistry.revoke(attestation_2.attestationId);
    }

    /*//////////////////////////////////////////////////////////////
                               revokeBatch TESTS
    //////////////////////////////////////////////////////////////*/

    function test_revokeBatch() external {
        Attestation[] memory attestations = new Attestation[](2);
        attestations[0] = attestation_1;
        attestations[1] = attestation_2;

        vm.assume(attestations.length > 0);
        for (uint i = 0; i < attestations.length; i++) {
            attestations[i].attestationId = bytes32(i);
            attestations[i].attestor = attestor_1;
        }

        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        vm.prank(attestor_1);
        masterRegistry.attestBatch(attestations);

        bytes32[] memory attestationIds = new bytes32[](attestations.length);
        for (uint i = 0; i < attestations.length; i++) {
            attestationIds[i] = attestations[i].attestationId;
        }

        vm.prank(attestor_1);
        masterRegistry.revokeBatch(attestationIds);

        for (uint i = 0; i < attestationIds.length; i++) {
            assertEq(
                masterRegistry.getAttestation(attestationIds[i]).revoked,
                true
            );
        }
    }

    function test_revokeBatch_InvalidBatchLength() external {
        bytes32[] memory invalidAttestationIds = new bytes32[](0);

        vm.expectRevert(IMasterRegistry.InvalidBatchLength.selector);
        masterRegistry.revokeBatch(invalidAttestationIds);
    }

    function test_revokeBatch_OnlyAttesteeOrAttestor(
        bytes32[] memory attestationIds
    ) external {
        vm.assume(attestationIds.length > 0);
        mockAttestorsRegistry.registerAttestor(attestor_1);
        vm.prank(owner);
        masterRegistry.setAttestorsRegistry(address(mockAttestorsRegistry));

        vm.startPrank(attestor_1);
        masterRegistry.attest(attestation_1);
        masterRegistry.attest(attestation_2);

        vm.expectRevert(IMasterRegistry.OnlyAttesteeOrAttestor.selector);
        masterRegistry.revokeBatch(attestationIds);
    }
}
