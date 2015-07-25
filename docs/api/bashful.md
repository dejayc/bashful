# Bashful Module: `bashful`

## Overview

**Purpose**: Provides functions to: track and determine whether Bashful modules have been loaded; inspect the state of variables and functions; write output to `STDOUT` and `STDERR`.

**Script**: [`bashful.inc.sh`](../../bashful.inc.sh)

**Unit Test Scripts**: No unit test scripts exist for `bashful`. 

**Requires Modules**: None

**Required By Modules**: [`error`](./error.md), [`opts`](./opts.md)

## Global Variables

Variable Name | Purpose
------------- | -------
<a name='bashful_loaded'></a>`BASHFUL_LOADED_[module_name]` | Exists for every Bashful module that has been loaded
<a name='bashful_path'></a>`BASHFUL_PATH` | The path in which Bashful modules are located
<a name='bashful_version'></a>`BASHFUL_VERSION` | The Bashful version number
<a name='script_debug_level'></a>`SCRIPT_DEBUG_LEVEL` | A script debugging level variable that can be used to determine whether certain types of output get echoed to the TTY
<a name='script_invoked_name'></a>`SCRIPT_INVOKED_NAME` | The path and name of the calling script
<a name='script_invoked_path'></a>`SCRIPT_INVOKED_PATH` | The path of the calling script
<a name='script_name'></a>`SCRIPT_NAME` | The name of the calling script
<a name='script_run_date'></a>`SCRIPT_RUN_DATE` | The date and time at which the script included Bashful

## Functions

### Function Index

Function Name | Description
------------- | -----------
[`ifDebug`](#ifdebug) | Returns true if the current debugging level is greater than or equal to the specified debugging level.
[`indexOf`](#indexof) | Searches for the first specified string within the subsequent list of string parameters, and returns the numeric index at which the searched string first occurs.
[`isFunction`](#isfunction) | Returns true if the specified function name exists as a defined function.
[`isModuleLoaded`](#ismoduleloaded) | Returns true if the specified Bashful module name has been loaded.
[`isScriptInteractive`](#isscriptinteractive) | Returns true if the currently executed script was invoked from an interactive TTY session.
[`isScriptSourced`](#isscriptsourced) | Returns true if the currently executed script was sourced, rather than executed.
[`isScriptSshCommand`](#isscriptsshcommand) | Returns true if the currently executed script was executed as an SSH command.
[`isVariableSet`](#isvariableset) | Returns true if the specified variable name exists as a defined variable, and is set.
[`stderr`](#stderr) | Echoes the piped input to `STDERR`, and returns the status code that was either passed in, or resulting from the last executed command.
[`stderr_ifDebug`](#stderr_ifdebug) | Echoes the piped input to `STDERR` if the current [`SCRIPT_DEBUG_LEVEL`](#script_debug_level) is greater than or equal to the specified debug level, and returns the status code that was either passed in, or resulting from the last executed command.
[`stdout`](#stdout) | Echoes the piped input to `STDOUT`, and returns the status code that was either passed in, or resulting from the last executed command.
[`stdout_ifDebug`](#stdout_ifdebug) | Echoes the piped input to `STDOUT` if the current [`SCRIPT_DEBUG_LEVEL`](#script_debug_level) is greater than or equal to the specified debug level, and returns the status code that was either passed in, or resulting from the last executed command.
[`verifyBashfulDependencies`](#verifybashfuldependencies) | Verifies that all required Bashful modules have been loaded as necessary.  If one or more required modules have not been loaded, generates an error message and returns a non-success status code.

### Function API

#### `ifDebug`

**Description**: Returns true if the current debugging level is greater than or equal to the specified debugging level.

#### `indexOf`

**Description**: Searches for the first specified string within the subsequent list of string parameters, and returns the numeric index at which the searched string first occurs.

#### `isFunction`

**Description**: Returns true if the specified function name exists as a defined function.

#### `isModuleLoaded`

**Description**: Returns true if the specified Bashful module name has been loaded.

#### `isScriptInteractive`

**Description**: Returns true if the currently executed script was invoked from an interactive TTY session.

#### `isScriptSourced`

**Description**: Returns true if the currently executed script was sourced, rather than executed.

#### `isScriptSshCommand`

**Description**: Returns true if the currently executed script was executed as an SSH command.

#### `isVariableSet`

**Description**: Returns true if the specified variable name exists as a defined variable, and is set.

#### `stderr`

**Description**: Echoes the piped input to `STDERR`, and returns the status code that was either passed in, or resulting from the last executed command.

#### `stderr_ifDebug`

**Description**: Echoes the piped input to `STDERR` if the current [`SCRIPT_DEBUG_LEVEL`](#script_debug_level) is greater than or equal to the specified debug level, and returns the status code that was either passed in, or resulting from the last executed command.

#### `stdout`

**Description**: Echoes the piped input to `STDOUT`, and returns the status code that was either passed in, or resulting from the last executed command.

#### `stdout_ifDebug`

**Description**: Echoes the piped input to `STDOUT` if the current [`SCRIPT_DEBUG_LEVEL`](#script_debug_level) is greater than or equal to the specified debug level, and returns the status code that was either passed in, or resulting from the last executed command.

#### `verifyBashfulDependencies`

**Description**: Verifies that all required Bashful modules have been loaded as necessary.  If one or more required modules have not been loaded, generates an error message and returns a non-success status code.
