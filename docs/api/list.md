# Bashful Module: `list`

## Overview

**Purpose**: Provides functions to join, split, and translate lists of strings.

**Unit Test Scripts**: [`tests/list.sh`](../../tests/list.sh) provides unit tests for the `list` module. 

Unit Test Group | Description
--------------- | -----------
`joinlist` | Unit tests for function [`joinedList`](#joinedlist)
`splitlist` | Unit tests for function [`splitList`](#splitlist)
`translist` | Unit tests for function [`translatedList`](#translatedList)

**Requires Modules**: [`text`](./text.md)

**Required By Modules**: [`match`](./match.md), [`seq`](./seq.md), [`ssh-spec`](./ssh-spec.md)

## Global Variables

Variable Name | Purpose
------------- | -------
<a name='bashful_loaded_list'></a>`BASHFUL_LOADED_list` | Declares that `list` has been loaded

## Functions

### Function Index

Function Name | Description
------------- | -----------
[`joinedList`](#joinedlist) | Returns a separated list of items, with each item separated from the next by the specified output separator.  The list of items is constructed from each argument passed in to this function.
[`splitList`](#splitlist) | Splits one or more delimited lists, and outputs a list in which each item is escaped in a way that protects spaces, quotes, and other special characters from being misinterpreted by the shell.
[`translatedList`](#translatedlist) | Returns a list of items separated by the specified output separator, optionally trimming whitespace from items, removing duplicate entries, and/or outputting the list in reverse order, according to the flags specified.

### Function API

#### `joinedList`

**Description**: Returns a separated list of items, with each item separated from the next by the specified output separator.  The list of items is constructed from each argument passed in to this function.

#### `splitList`

**Description**: Splits one or more delimited lists, and outputs a list in which each item is escaped in a way that protects spaces, quotes, and other special characters from being misinterpreted by the shell.

#### `translatedList`

**Description**: Returns a list of items separated by the specified output separator, optionally trimming whitespace from items, removing duplicate entries, and/or outputting the list in reverse order, according to the flags specified.
