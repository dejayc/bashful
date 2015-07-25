# Bashful Module: `seq`

## Overview

**Purpose**: Provides functions to generate permutations of sequences and sets..

**Unit Test Scripts**: [`tests/seq.sh`](../../tests/seq.sh) provides unit tests for the `seq` module. 

Unit Test Group | Description
--------------- | -----------
`intseq` | Unit tests for function [`intSeq`](#intseq)
`nvseq` | Unit tests for function [`nameValueSeq`](#namevalueseq)
`perseq` | Unit tests for function [`permutedSeq`](#permutedseq)
`perset` | Unit tests for function [`permutedSet`](#permutedset)

**Requires Modules**: [`list`](./list.md)

**Required By Modules**: [`ssh-spec`](./ssh-spec.md)

## Global Variables

Variable Name | Purpose
------------- | -------
<a name='bashful_loaded_seq'></a>`BASHFUL_LOADED_seq` | Declares that `seq` has been loaded

## Functions

### Function Index

Function Name | Description
------------- | -----------
[`intSeq`](#intseq) | Returns a separated list of non-negative integers, based on one or more input sequences of integers or integer ranges passed in as arguments.
[`nameValueSeq`](#namevalueseq) | Returns a separated list of name/value pairs, with each pair separated from the next by the specified pair separator, and each name separated from its value by the specified value separator.  Each argument passed into the function will be interpreted as a name/value pair to be separated into a name and value, according to the first occurrence of the specified value delimiter.  The name and/or value, if they contain text or numeric sequences, will be permuted into multiple resulting name/value pairs.
[`permutedSeq`](#permutedseq) | Returns a separated list of strings representing permutations of static text mingled with non-negative integer sequences or static text sequences.  The function reads each argument passed to it, and parses them by looking for embedded sequences within them.
[`permutedSet`](#permutedset) | Returns a separated list of permuted items.  Each argument passed into the function will be split by the input delimiter and turned into a set of items.  The set resulting from each argument will be permuted with every other set.

### Function API

#### `intSeq`

**Description**: Returns a separated list of non-negative integers, based on one or more input sequences of integers or integer ranges passed in as arguments. 

#### `nameValueSeq`

**Description**: Returns a separated list of name/value pairs, with each pair separated from the next by the specified pair separator, and each name separated from its value by the specified value separator.  Each argument passed into the function will be interpreted as a name/value pair to be separated into a name and value, according to the first occurrence of the specified value delimiter.  The name and/or value, if they contain text or numeric sequences, will be permuted into multiple resulting name/value pairs.

#### `permutedSeq`

**Description**: Returns a separated list of strings representing permutations of static text mingled with non-negative integer sequences or static text sequences.  The function reads each argument passed to it, and parses them by looking for embedded sequences within them.

#### `permutedSet`

**Description**: Returns a separated list of permuted items.  Each argument passed into the function will be split by the input delimiter and turned into a set of items.  The set resulting from each argument will be permuted with every other set.
