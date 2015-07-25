# Bashful Module: `match`

## Overview

**Purpose**: Provides functions to match wildcards within strings, and retrieve values for matching keys within a list of key/value pairs.

**Unit Test Scripts**: [`tests/match.sh`](../../tests/match.sh) provides unit tests for the `match` module. 

Unit Test Group | Description
--------------- | -----------
`ifWc` | Unit tests for function [`ifWildcardMatches`](#ifwildcardmatches)
`valname` | Unit tests for function [`valueForMatchedName`](#valueformatchedname)

**Requires Modules**: [`list`](./list.md), [`text`](./text.md)

**Required By Modules**: [`ssh-spec`](./ssh-spec.md)

## Global Variables

Variable Name | Purpose
------------- | -------
<a name='bashful_loaded_xyz'></a>`BASHFUL_LOADED_match` | Declares that `match` has been loaded

## Functions

### Function Index

Function Name | Description
------------- | -----------
[`ifWildcardMatches`](#ifwildcardmatches) | Returns status `0` if the second passed parameter, when interpreted as a wildcard, matches the first passed parameter.  Otherwise, returns `1`. Wildcard characters asterisk `*` and question mark `?` are treated as special wildcard characters, with `*` matching any sequence of characters, and `?` matching any single character.  All other characters are treated as literal characters.
[`valueForMatchedName`](#valueformatchedname) | Accepts a name as the first argument, and any number of name/value pairs as subsequent arguments, and returns the value of the first name/value pair that matches the specified name.  If no match is found, returns the status code `1`.

### Function API

#### `ifWildcardMatches`

**Description**: Returns status `0` if the second passed parameter, when interpreted as a wildcard, matches the first passed parameter.  Otherwise, returns `1`. Wildcard characters asterisk `*` and question mark `?` are treated as special wildcard characters, with `*` matching any sequence of characters, and `?` matching any single character.  All other characters are treated as literal characters.

#### `valueForMatchedName`

**Description**: Accepts a name as the first argument, and any number of name/value pairs as subsequent arguments, and returns the value of the first name/value pair that matches the specified name.  If no match is found, returns the status code `1`.
