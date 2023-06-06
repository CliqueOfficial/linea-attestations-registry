# LINEA ATTESTATION LAYER

The Linea Attestation Layer is a protocol on which attestors can attest data to attestees.
Furthermore the modular design allows for builders to build components on top of the protocol to extend its use.

## Design

![Linea Attestation Layer Image](./docs/lal.png)

### Master Registry

This registry serves as a repository for all attestation instances. Its primary role is to:

- Record and maintain all attestations.

### Schemas Registry

The Schemas Registry outlines and holds the structure of the attestation data, playing a pivotal role in data representation. It is tasked with:

- Recording and storing all schemas, which define the structure and representation of attestation data

### Attestors Registry

The Attestors Registry functions as the portal for attesting data to the master registry. Attestor smart contracts need to adhere to certain standards, including:

- Being capable of handling an array of modules
- Validating every module for each attestation before affirming the data
- Inheriting from the "Attestor" base contract

### Modules Registry

The Modules Registry is the space where smart contracts implementing specific business logic, known as modules, are stored. Each module must meet the following criteria:

- Be recorded in the Module Registry
- Inherit from the "Module" base class
- This layered and organized structure allows for seamless integration and facilitates the management and verification of attestations.
