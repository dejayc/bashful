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
