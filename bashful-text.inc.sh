#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Declare the module name.
declare BASHFUL_MODULE='text'

# Verify execution context and module dependencies, and register the module.
{
    declare BASHFUL_MODULE_VAR="BASHFUL_LOADED_${BASHFUL_MODULE}"
    [[ -z "${!BASHFUL_MODULE_VAR-}" ]] || return 0

    # Ensure the module is sourced, not executed, generating an error
    # otherwise.
    [[ "${BASH_ARGV}" != '' ]] || {
        echo "ERROR: ${BASH_SOURCE[0]##*/} must be sourced, not executed"
        exit 1
    } >&2

    # Register the module.
    declare "${BASHFUL_MODULE_VAR}"="${BASHFUL_MODULE}"
}

# function escapedExtendedRegex
#
# Returns an escaped representation of the passed string, with each character
# preceded by a backslash if the character is a special POSIX extended regular
# expression character.  Special characters are '\', '.', '?', '*', '+', '{',
# '}', '-', '^', '$', '|', '(', and ')'.
#
# Examples:
#
# $ escapedExtendedRegex 'Hello? I need $5 (please)'
# Hello\? I need \$5 \(please\)
function escapedExtendedRegex()
{
    local REGEX="${1-}"

    # These following variables exist to prevent various bash shell versions,
    # and even syntax highlighting in different text editors, from becoming
    # confused due to discrepancies in how they handle backslash escaping.
    local RB='}'
    local LP='('

    # Replace all the special characters wth their escaped counterparts.
    REGEX="${REGEX//[\\]/\\\\}"
    REGEX="${REGEX//[.]/\\.}"
    REGEX="${REGEX//[?]/\\?}"
    REGEX="${REGEX//[*]/\\*}"
    REGEX="${REGEX//[+]/\\+}"
    REGEX="${REGEX//[{]/\\{}"
    REGEX="${REGEX//[\}]/\\${RB}}"
    REGEX="${REGEX//[-]/\\-}"
    REGEX="${REGEX//[\^]/\\^}"
    REGEX="${REGEX//[\$]/\\\$}"
    REGEX="${REGEX//[|]/\\|}"
    REGEX="${REGEX//[\(]/\\${LP}}"
    REGEX="${REGEX//[\)]/\\)}"
    echo -n "${REGEX}"
}

# function orderedBracketExpression
#
# Returns an ordered POSIX bracket expression for the passed argument,
# ensuring that within the bracket expression, right-bracket ']' appears
# first, if it appears, and dash '-' appears last, if it appears.  All
# other symbols will remain in their present order, and all duplicate symbols
# are discarded.  Backslash '\' will be escaped with another backslash,
# appearing as '\\'.
#
# Note that this function is only meant to reorder bracket expressions that
# do not contain character classes, collating symbols, or character ranges.
#
# When using unsanitized variables to dynamically specify the matching
# characters within the POSIX bracket expression of a regular expression,
# guaranteeing the proper order of special characters within the bracket
# expression can help eliminate errors related to the matching process.
#
# Examples:
#
# $ orderedBracketExpression ',;[(\-)]'
# ],;[(\\)-
#
# $ orderedBracketExpression ',;--,--;--'
# ,;-
#
# $ orderedBracketExpression ',;--,]--;--'
# ],;-
function orderedBracketExpression()
{
    local EXPR="${1-}"

    declare -i HAS_DASH=0
    declare -i HAS_RIGHT_BRACKET=0
    local ORDERED=''

    [[ "${EXPR}" =~ []] ]] && {

        let HAS_RIGHT_BRACKET=1
        EXPR="${EXPR//]/}"
    }

    [[ "${EXPR}" =~ - ]] && {

        let HAS_DASH=1
        EXPR="${EXPR//-/}"
    }

    local UNIQUE="${EXPR}"
    EXPR=''

    while [ -n "${UNIQUE}" ]
    do
        local CHAR="${UNIQUE:0:1}"
        [[ "${CHAR}" == '\' ]] && CHAR='\\'
        EXPR="${EXPR}${CHAR}"
        UNIQUE="${UNIQUE//${CHAR}/}"
    done

    [[ ${HAS_RIGHT_BRACKET} -eq 0 ]] || echo -n ']'

    echo -n "${EXPR}"

    [[ ${HAS_DASH} -eq 0 ]] || echo -n '-'
    true # true prevents 'set -e' from aborting
}

# function trimmed:
#
# Returns the argument passed into this function, with leading and trailing
# whitespace trimmed.  To trim multiple arguments, please refer to the
# function 'translatedList' in 'bashful-list'.
#
# Examples:
#
# $ printf '['; trimmed ''; printf ']'
# []
#
# $ printf '['; trimmed 'none'; printf ']'
# [none]
#
# $ printf '['; trimmed '  leading'; printf ']'
# [leading]
#
# $ printf '['; trimmed 'trailing  '; printf ']'
# [trailing]
#
# $ printf '['; trimmed '  both  '; printf ']'
# [both]
#
# $ printf '['; trimmed '  embedded ws  '; printf ']'
# [embedded ws]
function trimmed()
{
    local TEXT="${1-}"
    TEXT="${TEXT#"${TEXT%%[![:space:]]*}"}"
    echo -n "${TEXT%"${TEXT##*[![:space:]]}"}"
}

# function trimmedLeading:
#
# Returns the argument passed into this function, with leading whitespace
# trimmed.  To trim multiple arguments, please refer to the function
# 'translatedList' in 'bashful-list'.
#
# Examples:
#
# $ printf '['; trimmedLeading ''; printf ']'
# []
#
# $ printf '['; trimmedLeading 'none'; printf ']'
# [none]
#
# $ printf '['; trimmedLeading '  leading'; printf ']'
# [leading]
#
# $ printf '['; trimmedLeading 'trailing  '; printf ']'
# [trailing  ]
#
# $ printf '['; trimmedLeading '  both  '; printf ']'
# [both  ]
#
# $ printf '['; trimmedLeading '  embedded ws  '; printf ']'
# [embedded ws  ]
function trimmedLeading()
{
    local TEXT="${1-}"
    echo -n "${TEXT#"${TEXT%%[![:space:]]*}"}"
}

# function trimmedTrailing:
#
# Returns the argument passed into this function, with trailing whitespace
# trimmed.  To trim multiple arguments, please refer to the function
# 'translatedList' in 'bashful-list'.
#
# Examples:
#
# $ printf '['; trimmedTrailing ''; printf ']'
# []
#
# $ printf '['; trimmedTrailing 'none'; printf ']'
# [none]
#
# $ printf '['; trimmedTrailing '  leading'; printf ']'
# [  leading]
#
# $ printf '['; trimmedTrailing 'trailing  '; printf ']'
# [trailing]
#
# $ printf '['; trimmedTrailing '  both  '; printf ']'
# [  both]
#
# $ printf '['; trimmedTrailing '  embedded ws  '; printf ']'
# [  embedded ws]
function trimmedTrailing()
{
    local TEXT="${1-}"
    echo -n "${TEXT%"${TEXT##*[![:space:]]}"}"
}
