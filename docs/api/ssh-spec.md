# Bashful Module: `ssh-spec`

## Overview

**Purpose**: Provides functions to parse an advanced syntax that describes SSH connections, and the possible certificates and jump servers they might use.

**Unit Test Scripts**: [`tests/sshs.sh`](../../tests/sshs.sh) provides unit tests for the `ssh-spec` module. 

Unit Test Group | Description
--------------- | -----------
`parspec` | Unit tests for function [`parsedSshSpecs`](#parsedsshspecs)
`permap` | Unit tests for function [`permutedSshMap`](#permutedsshmap)
`valhost` | Unit tests for function [`valueForMatchedSshHost`](#valueformatchedsshhost)
`valhosts` | Unit tests for function [`valuesForMatchedSshHosts`](#valuesformatchedsshhosts)

**Requires Modules**: [`list`](./list.md), [`match`](./match.md), [`seq`](./seq.md)

**Required By Modules**: None

## Global Variables

Variable Name | Purpose
------------- | -------
<a name='bashful_loaded_ssh_spec'></a>`BASHFUL_LOADED_ssh_spec` | Declares that `ssh_spec` has been loaded

## Functions

### Function Index

Function Name | Description
------------- | -----------
[`parsedSshSpecs`](#parsedsshspecs) | Returns a series of connection parameters that represents one or more SSH connections, based upon multiple criteria passed to this function.  Useful for scripts that need to established elaborate SSH connections.
[`permutedSshMap`](#permutedsshmap) | Returns a map, where each map entry consists of an SSH host descriptor mapped to some relevant parameter.
[`valueForMatchedSshHost`](#valueformatchedsshhost) | From a series of passed arguments that represent mappings between SSH host descriptors and arbitrary values, returns the value from the first mapping whose SSH host descriptor matches the specified SSH host.  The first argument passed to this function is interpreted as the SSH host to search for.  All subsequent arguments are interpreted as mappings between SSH host descriptors and arbitrary values.
[`valuesForMatchedSshHosts`](#valuesformatchedsshhosts) | Accepts as the first argument a delimited map of SSH host descriptors mapped to parameter values; and as a series of subsequent arguments, a list of SSH hosts; and for each SSH host in the list, returns the corresponding value that is mapped to the first SSH host descriptor that matches the host.

### Function API

#### `parsedSshSpecs`

**Description**: Returns a series of connection parameters that represents one or more SSH connections, based upon multiple criteria passed to this function.  Useful for scripts that need to established elaborate SSH connections.

#### `permutedSshMap`

**Description**: Returns a map, where each map entry consists of an SSH host descriptor mapped to some relevant parameter.

#### `valueForMatchedSshHost`

**Description**: From a series of passed arguments that represent mappings between SSH host descriptors and arbitrary values, returns the value from the first mapping whose SSH host descriptor matches the specified SSH host.  The first argument passed to this function is interpreted as the SSH host to search for.  All subsequent arguments are interpreted as mappings between SSH host descriptors and arbitrary values.

#### `valuesForMatchedSshHosts`

**Description**: Accepts as the first argument a delimited map of SSH host descriptors mapped to parameter values; and as a series of subsequent arguments, a list of SSH hosts; and for each SSH host in the list, returns the corresponding value that is mapped to the first SSH host descriptor that matches the host.
