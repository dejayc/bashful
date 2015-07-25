# Bashful Module: `text`

## Overview

**Purpose**: Provides functions to trim and escape text representations.

**Unit Test Scripts**: [`tests/text.sh`](../../tests/text.sh) provides unit tests for the `text` module. 

Unit Test Group | Description
--------------- | -----------
`escEre` | Unit tests for function [`escapedExtendedRegex`](#escapedextendedregex)
`ltrim` | Unit tests for function [`trimmedLeading`](#trimmedleading)
`ordBe` | Unit tests for function [`orderedBracketExpression`](#orderedbracketexpression)
`rtrim` | Unit tests for function [`trimmedTrailing`](#trimmedtrailing)
`trim` | Unit tests for function [`trimmed`](#trimmed)

**Requires Modules**: None

**Required By Modules**: [`list`](./list.md), [`match`](./match.md)

## Global Variables

Variable Name | Purpose
------------- | -------
<a name='bashful_loaded_text'></a>`BASHFUL_LOADED_text` | Declares that `text` has been loaded

## Functions

### Function Index

Function Name | Description
------------- | -----------
[`escapedExtendedRegex`](#escapedextendedregex) | Returns an escaped representation of the passed string, with each character preceded by a backslash if the character is a special POSIX extended regular expression character.  Special characters are `\`, `.`, `?`, `*`, `+`, `{`, `}`, `-`, `^`, `$`, `&#124;`, `(`, and `)`.
[`orderedBracketExpression`](#orderedbracketexpression) | Returns an ordered POSIX bracket expression for the passed argument, ensuring that within the bracket expression, right-bracket `]` appears first, if it appears, and dash `-` appears last, if it appears.  All other symbols will remain in their present order, and all duplicate symbols are discarded.  Backslash `\` will be escaped with another backslash, appearing as `\\`.
[`trimmed`](#trimmed) | Returns the argument passed into this function, with leading and trailing whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).
[`trimmedLeading`](#trimmedleading) | Returns the argument passed into this function, with leading whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).
[`trimmedTrailing`](#trimmedTrailing) | Returns the argument passed into this function, with trailing whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).

### Function API

#### `escapedExtendedRegex`

**Description**: Returns an escaped representation of the passed string, with each character preceded by a backslash if the character is a special POSIX extended regular expression character.  Special characters are `\`, `.`, `?`, `*`, `+`, `{`, `}`, `-`, `^`, `$`, `&#124;`, `(`, and `)`.

#### `orderedBracketExpression`

**Description**: Returns an ordered POSIX bracket expression for the passed argument, ensuring that within the bracket expression, right-bracket `]` appears first, if it appears, and dash `-` appears last, if it appears.  All other symbols will remain in their present order, and all duplicate symbols are discarded.  Backslash `\` will be escaped with another backslash, appearing as `\\`.

#### `trimmed`

**Description**: Returns the argument passed into this function, with leading and trailing whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).

#### `trimmedLeading`

**Description**: Returns the argument passed into this function, with leading whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).

#### `trimmedTrailing`

**Description**: Returns the argument passed into this function, with trailing whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).
