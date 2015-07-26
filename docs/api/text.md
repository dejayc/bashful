# Bashful Module: `text`

## Overview

**Purpose**: Provides functions to trim and escape text representations.

**Unit Test Scripts**: [`tests/text.sh`](../../tests/text.sh) provides unit tests for the `text` module. 

Unit Test Group | Description
--------------- | -----------
`escEre` | Unit tests for function [`escapedExtendedRegex`](#function-escapedextendedregex)
`ltrim` | Unit tests for function [`trimmedLeading`](#function-trimmedleading)
`ordBe` | Unit tests for function [`orderedBracketExpression`](#function-orderedbracketexpression)
`rtrim` | Unit tests for function [`trimmedTrailing`](#function-trimmedtrailing)
`trim` | Unit tests for function [`trimmed`](#function-trimmed)

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
[`escapedExtendedRegex`](#function-escapedextendedregex) | Returns an escaped representation of the passed string, with each character preceded by a backslash if the character is a special POSIX extended regular expression character.  Special characters are `\`, `.`, `?`, `*`, `+`, `{`, `}`, `-`, `^`, `$`, `&#124;`, `(`, and `)`.
[`orderedBracketExpression`](#function-orderedbracketexpression) | Returns an ordered POSIX bracket expression for the passed argument, ensuring that within the bracket expression, right-bracket `]` appears first, if it appears, and dash `-` appears last, if it appears.  All other symbols will remain in their present order, and all duplicate symbols are discarded.  Backslash `\` will be escaped with another backslash, appearing as `\\`.
[`trimmed`](#function-trimmed) | Returns the argument passed into this function, with leading and trailing whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).
[`trimmedLeading`](#function-trimmedleading) | Returns the argument passed into this function, with leading whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).
[`trimmedTrailing`](#function-trimmedTrailing) | Returns the argument passed into this function, with trailing whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).

### Function API

#### Function: `escapedExtendedRegex`

**Description**: Returns an escaped representation of the passed string, with each character preceded by a backslash if the character is a special POSIX extended regular expression character.  Special characters are `\`, `.`, `?`, `*`, `+`, `{`, `}`, `-`, `^`, `$`, `&#124;`, `(`, and `)`.

**Examples**:
```
escapedExtendedRegex 'Hello? I need $5 (please)'
Hello\? I need \$5 \(please\)
```

#### Function: `orderedBracketExpression`

**Description**: Returns an ordered POSIX bracket expression for the passed argument, ensuring that within the bracket expression, right-bracket `]` appears first, if it appears, and dash `-` appears last, if it appears.  All other symbols will remain in their present order, and all duplicate symbols are discarded.  Backslash `\` will be escaped with another backslash, appearing as `\\`.

Note that this function is only meant to reorder bracket expressions that do not contain character classes, collating symbols, or character ranges.

When using unsanitized variables to dynamically specify the matching characters within the POSIX bracket expression of a regular expression, guaranteeing the proper order of special characters within the bracket expression can help eliminate errors related to the matching process.

**Examples**:
```
orderedBracketExpression ',;[(\-)]'
],;[(\\)-

orderedBracketExpression ',;--,--;--'
,;-

orderedBracketExpression ',;--,]--;--'
],;-
```

#### Function: `trimmed`

**Description**: Returns the argument passed into this function, with leading and trailing whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).

**Examples**:
```
printf '['; trimmed ''; printf ']'
[]

printf '['; trimmed 'none'; printf ']'
[none]

printf '['; trimmed '  leading'; printf ']'
[leading]

printf '['; trimmed 'trailing  '; printf ']'
[trailing]

printf '['; trimmed '  both  '; printf ']'
[both]

printf '['; trimmed '  embedded ws  '; printf ']'
[embedded ws]
```

#### Function: `trimmedLeading`

**Description**: Returns the argument passed into this function, with leading whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).

**Examples**:
```
printf '['; trimmedLeading ''; printf ']'
[]

printf '['; trimmedLeading 'none'; printf ']'
[none]

printf '['; trimmedLeading '  leading'; printf ']'
[leading]

printf '['; trimmedLeading 'trailing  '; printf ']'
[trailing  ]

printf '['; trimmedLeading '  both  '; printf ']'
[both  ]

printf '['; trimmedLeading '  embedded ws  '; printf ']'
[embedded ws  ]
```

#### Function: `trimmedTrailing`

**Description**: Returns the argument passed into this function, with trailing whitespace trimmed.  To trim multiple arguments, please refer to the function [`translatedList`](./list.md#translatedlist) in [`bashful-list`](./list.md).

**Examples**:
```
printf '['; trimmedTrailing ''; printf ']'
[]

printf '['; trimmedTrailing 'none'; printf ']'
[none]

printf '['; trimmedTrailing '  leading'; printf ']'
[  leading]

printf '['; trimmedTrailing 'trailing  '; printf ']'
[trailing]

printf '['; trimmedTrailing '  both  '; printf ']'
[  both]

printf '['; trimmedTrailing '  embedded ws  '; printf ']'
[  embedded ws]
```
