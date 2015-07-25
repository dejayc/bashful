# Bashful Module: `path`

## Overview

**Purpose**: Provides functions to inspect and normalize filesystem paths.

**Unit Test Scripts**: No unit test scripts exist for `path`. 

**Requires Modules**: None

**Required By Modules**: None

## Global Variables

Variable Name | Purpose
------------- | -------
<a name='bashful_loaded_path'></a>`BASHFUL_LOADED_path` | Declares that `path` has been loaded

## Functions

### Function Index

Function Name | Description
------------- | -----------
[`hasLeadingSlash`](#hasleadingslash) | Returns the status of whether the passed path string has a leading slash.
[`hasParentPathReference`](#hasparentpathreference) | Returns the status of whether the passed path string contains parent path (e.g. `..` ) components.
[`hasTrailingSlash`](#hastrailingslash) | Returns the status of whether the passed path string has a trailing slash.
[`normalizePath`](#normalizepath) | Removes superfluous path components (e.g. `/./`, `//`) from the passed path string.
[`readPath`](#readpath) | Attempts to navigate to the specified path, and echoes the actual, absolute path as reported by the OS.  This removes all relative components from the path (e.g. `.`, `..`, `//` ).

### Function API

#### `hasLeadingSlash`

**Description**: Returns the status of whether the passed path string has a leading slash.

#### `hasParentPathReference`

**Description**: Returns the status of whether the passed path string contains parent path (e.g. `..` ) components.

#### `hasTrailingSlash`

**Description**: Returns the status of whether the passed path string has a trailing slash.

#### `normalizePath`

**Description**: Removes superfluous path components (e.g. `/./`, `//`) from the passed path string.

#### `readPath`

**Description**: Attempts to navigate to the specified path, and echoes the actual, absolute path as reported by the OS.  This removes all relative components from the path (e.g. `.`, `..`, `//` ).
