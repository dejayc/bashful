# Bashful Module: `list`

## Overview

**Purpose**: Provides functions to join, split, and translate lists of strings.

**Unit Test Scripts**: [`tests/list.sh`](../../tests/list.sh) provides unit tests for the `list` module. 

Unit Test Group | Description
--------------- | -----------
`joinlist` | Unit tests for function [`joinedList`](#function-joinedlist)
`splitlist` | Unit tests for function [`splitList`](#function-splitlist)
`translist` | Unit tests for function [`translatedList`](#function-translatedlist)

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
[`joinedList`](#function-joinedlist) | Returns a separated list of items, with each item separated from the next by the specified output separator.  The list of items is constructed from each argument passed in to this function.
[`splitList`](#function-splitlist) | Splits one or more delimited lists, and outputs a list in which each item is escaped in a way that protects spaces, quotes, and other special characters from being misinterpreted by the shell.
[`translatedList`](#function-translatedlist) | Returns a list of items separated by the specified output separator, optionally trimming whitespace from items, removing duplicate entries, and/or outputting the list in reverse order, according to the flags specified.

### Function API

#### Function: `joinedList`

**Description**: Returns a separated list of items, with each item separated from the next by the specified output separator.  The list of items is constructed from each argument passed in to this function.

**Parameters**:
`-q`: optionally escapes each item being output, in a way that protects spaces, quotes, and other special characters from being misinterpreted by the shell.  Useful for assigning the output of this function to an array, via the following construct:
```
declare -a ARRAY="( `joinedList -q "${INPUT_ARRAY[@]}"` )"
```
Note that while this option can be used simultaneously with an output separator specified via `-s`, such usage is not guaranteed to be parsable, depending upon the value of the separator.

`-s`: optionally specifies an output separator.  Defaults to ' '.

`-S`: optionally appends an output separator at the end of the output.  By default, no output separator appears at the end of the output.  If an output separator already exists at the end of the output because the last item is null, an additional output separator will not be appended.

**Examples:**
```
joinedList -s ',' a b c d e
a,b,c,d,e

joinedList -s ';' -S a b c d e
a;b;c;d;e;

joinedList -s ',' a ''
a,,

joinedList -s ',' -S a ''
a,,

joinedList -s ',' '' ''
,,

joinedList -q '' ''
'' '' 

joinedList -q 'hello there' 'my "friend"'
hello\ there my\ \"friend\"

joinedList -q -s ';' 'hello there' 'my "friend"'
hello\ there;my\ \"friend\"
```

#### Function: `splitList`

**Description**: Splits one or more delimited lists, and outputs a list in which each item is escaped in a way that protects spaces, quotes, and other special characters from being misinterpreted by the shell.

Useful for assigning the output of this function to an array, via the following construct:
```
declare -a ARRAY="( `splitList 'arg1 arg2 arg3 etc.'` )"
```

**Parameters**:
`-d`: optionally specifies one or more input delimiter characters.  Defaults to `$IFS`.  If null, splits every string into an array of characters.

`-e`: optionally protects instances of escaped delimeter characters.  For example, if delimter `;` is specified, and an instance of `;` must appear within a list element without being interpreted as a delimiter, that character may be represented as `\;` without being interpreted as a delimeter, if `-e` is specified.

**Examples:**
```
splitList -d ',' 'a,b' ',c'
a b '' c

splitList -d ',' 'a,'
a

splitList -d ',' 'a,,'
a ''

splitList -d ',' ',,'
'' ''

splitList -d ',' 'a,b,' ',c'
a b '' c

splitList -d ',' 'a,b,,' ',c'
a b '' '' c

splitList -d ',' 'a,b\,' ',c'
a b\\ '' c

splitList -d ',' -e 'a,b\,' ',c'
a b, '' c

splitList -d ',' -e 'a\,b,'
a\, b

splitList -d ',' 'hello,there' 'my "friend"'
hello there my\ \"friend\"

splitList -d '' 'hi there' 'bye'
h i \  t h e r e b y e
```

#### Function: `translatedList`

**Description**: Returns a list of items separated by the specified output separator, optionally trimming whitespace from items, removing duplicate entries, and/or outputting the list in reverse order, according to the flags specified.

**Parameters**:
`-l`: optionally trims leading whitespace from each set item.

`-n`: optionally preserves null items.

`-q`: optionally escapes each item being output, in a way that protects spaces, quotes, and other special characters from being misinterpreted by the shell.  Useful for assigning the output of this function to an array, via the following construct:
```
declare -a ARRAY="( `translatedList -q "${INPUT_ARRAY[@]}"` )"
```
Note that while this option can be used simultaneously with an output separator specified via `-s`, such usage is not guaranteed to be parsable, depending upon the value of the separator.

`-r`: optionally processes the set in reverse order, outputting the set in reverse order, and eliminating duplicate items in reverse order when `-u` is specified.

`-s`: optionally specifies an output separator for each set item.  Defaults to ' '.

`-S`: optionally appends an output separator at the end of the output.  By default, no output separator appears at the end of the output.

`-t`: optionally trims trailing whitespace from each set item.

`-T`: optionally trims leading and trailing whitespace from each set item.

`-u`: optionally outputs only unique items, discarding duplicates from the output.

**Examples:**
```
translatedList a b a c b d a
a b a c b d a

translatedList -r a b a c b d a
a d b c a b a

translatedList -u a b a c b d a
a b c d

translatedList -r -u a b a c b d a
a d b c

translatedList -s ';' -S a b a c b d a
a;b;a;c;b;d;a;

translatedList -l '[' '  leading' '  both  ' 'trailing  ' ']'
[ leading both   trailing   ]

translatedList -t '[' '  leading' '  both  ' 'trailing  ' ']'
[   leading   both trailing ]

translatedList -T '[' '  leading' '  both  ' 'trailing  ' ']'
[ leading both trailing ]

translatedList -l -t '[' '  leading' '  both  ' 'trailing  ' ']'
[ leading both trailing ]

translatedList -s ',' 1 2 '' 4 '' 5
1,2,4,5

translatedList -s ',' -n 1 2 '' 4 '' 5
1,2,,4,,5

translatedList -s ',' -n -u 1 2 '' 4 '' 5
1,2,,4,5

translatedList -q 'hello there' 'my "friend"' '`whoami`'
hello\ there my\ \"friend\" \`whoami\`

translatedList -s ',' -q 'hello there' 'my "friend"'
hello\ there,my\ \"friend\" \`whoami\`
```
