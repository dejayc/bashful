# Bashful Module: `error`

## Overview

**Purpose**: Provides functions to generate error messages for common error scenarios.

**Script**: [`bashful-error.inc.sh`](../../bashful-error.inc.sh)

**Unit Test Scripts**: No unit test scripts exist for `error`.

**Requires Modules**: [`bashful`](./bashful.md)

**Required By Modules**: None

## Global Variables

Variable Name | Purpose
------------- | -------
<a name='bashful_loaded_error'></a>`BASHFUL_LOADED_error` | Declares that `error` has been loaded

## Functions

### Function Index

Function Name | Description
------------- | -----------
[`ERROR_commandExecution`](#error_commandexecution) | Generates a message that indicates an error has occurred while executing a command.  Returns a non-success status code.
[`ERROR_commandNotExecutable`](#error_commandnotexecutable) | Generates a message that indicates an error has occurred while executing a command that was not executable.  Returns a non-success status code.
[`ERROR_invalidSettingValue`](#error_invalidsettingvalue) | Generates a message that indicates a setting has an invalid value.  Returns a non-success status code.
[`ERROR_missingSetting`](#error_missingsetting) | Generates a message that indicates a required setting is missing.  Returns a non-success status code.

### Function API

#### `ERROR_commandExecution`

**Description**: Generates a message that indicates an error has occurred while executing a command.  Returns a non-success status code.

#### `ERROR_commandNotExecutable`

**Description**: Generates a message that indicates an error has occurred while executing a command that was not executable.  Returns a non-success status code.

#### `ERROR_invalidSettingValue`

**Description**: Generates a message that indicates a setting has an invalid value.  Returns a non-success status code.

#### `ERROR_missingSetting`

**Description**: Generates a message that indicates a required setting is missing.  Returns a non-success status code.
