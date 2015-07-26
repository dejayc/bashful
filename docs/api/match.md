# Bashful Module: `match`

## Overview

**Purpose**: Provides functions to match wildcards within strings, and retrieve values for matching keys within a list of key/value pairs.

**Unit Test Scripts**: [`tests/match.sh`](../../tests/match.sh) provides unit tests for the `match` module. 

Unit Test Group | Description
--------------- | -----------
`ifWc` | Unit tests for function [`ifWildcardMatches`](#function-ifwildcardmatches)
`valname` | Unit tests for function [`valueForMatchedName`](#function-valueformatchedname)

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
[`ifWildcardMatches`](#function-ifwildcardmatches) | Returns status `0` if the second passed parameter, when interpreted as a wildcard, matches the first passed parameter.  Otherwise, returns `1`. Wildcard characters asterisk `*` and question mark `?` are treated as special wildcard characters, with `*` matching any sequence of characters, and `?` matching any single character.  All other characters are treated as literal characters.
[`valueForMatchedName`](#function-valueformatchedname) | Accepts a name as the first argument, and any number of name/value pairs as subsequent arguments, and returns the value of the first name/value pair that matches the specified name.  If no match is found, returns the status code `1`.

### Function API

#### Function: `ifWildcardMatches`

**Description**: Returns status `0` if the second passed parameter, when interpreted as a wildcard, matches the first passed parameter.  Otherwise, returns `1`. Wildcard characters asterisk `*` and question mark `?` are treated as special wildcard characters, with `*` matching any sequence of characters, and `?` matching any single character.  All other characters are treated as literal characters.

**Examples**:
```
ifWildcardMatches 'tortoise' 'tortoise'; echo ${?}
0

ifWildcardMatches 'tortoise' 'porpoise'; echo ${?}
1

ifWildcardMatches 'tortoise' '?or?oise'; echo ${?}
0

ifWildcardMatches 'tortoise' '*oise'; echo ${?}
0

ifWildcardMatches 'tortoise' 'tort'; echo ${?}
1
```

#### Function: `valueForMatchedName`

**Description**: Accepts a name as the first argument, and any number of name/value pairs as subsequent arguments, and returns the value of the first name/value pair that matches the specified name.  If no match is found, returns the status code `1`.

**Parameters**:
`-l`: optionally returns the value of the last name/value pair that matches the specified name.  By default, the value of the first name/value pair that matches the specified name is returned.

`-d`: optionally specifies one or more value delimiter characters.  The first occurrence of an input delimiter within a name/value pair will be used to split the name and value.  All subsequent occurrences will be considered part of the value.  Defaults to `=`.  An error is returned if null.

`-t`: optionally trims leading and trailing whitespace from the name, and each name and value in name/value pairs.

`-v`: optionally treats arguments without an input delimiter as a value with a null name.  By default, such entries are treated as a name with a null value.

`-w`: optionally performs wildcard matching, interpreting the name within each name/value pair as a wildcard against which to compare the name argument.

**Examples**:
```
valueForMatchedName '3' '1=a' '2=b' '3=c'
c

valueForMatchedName -w 'book' 'b*=1' 'bo*=2' 'b?o*=3'
1

valueForMatchedName -w 'book' 'b* = 1' 'bo*=2'
2

valueForMatchedName -t -w '  book  ' 'b* = 1' 'bo*=2'
1

valueForMatchedName -w -l 'book' 'b*=1' 'bo*=2' 'b?o*=3'
3

valueForMatchedName '' 'empty' '=value'
value

valueForMatchedName -v '' 'empty' '=value'
empty
```
