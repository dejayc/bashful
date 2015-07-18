#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Declare the module name.
declare BASHFUL_MODULE='path'

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

# Returns the status of whether the passed path string has a leading slash.
function hasLeadingSlash()
{
    echo "${1-}" | grep -q -E -e '^[/]'
}

# Returns the status of whether the passed path string contains parent path
# (e.g. '..' ) components.
function hasParentPathReference()
{
    echo "${1-}" | grep -q -E -e '(^[.][.][/]|[/][.][.][/]|[/][.][.]$|^[.][.]$)'
}

# Returns the status of whether the passed path string has a trailing slash.
function hasTrailingSlash()
{
    echo "${1-}" | grep -q -E -e '[/]$'
}

# Removes superfluous path components (e.g. '/./', '//') from the passed path
# string.
function normalizePath()
{
    local NORM_PATH="${1-}"
    local PREV_PATH

    while [ "${PREV_PATH}" != "${NORM_PATH}" ]
    do
        PREV_PATH="${NORM_PATH}"
        NORM_PATH="$( echo "${NORM_PATH}" | sed \
            -e 's:^[.][/]:/:' \
            -e 's:[/][.]$:/:' \
            -e 's:[/][/]*:/:g' \
            -e 's:[/][.][/]\([.][/]\)*:/:g' )"
    done
    echo "${NORM_PATH}"
}

# Attempts to navigate to the specified path, and echoes the actual, absolute
# path as reported by the OS.  This removes all relative components from the
# path (e.g. '.', '..', '//' ).
#
# In the event that the path does not exist, or permissions restrict the path
# from being accessible, an error code is returned, and the error message
# reported by the 'cd' command is echoed.  To surpress error messages, pass
# 'quiet' as the second parameter to this function.
function readPath()
{
    local REAL_PATH="${1-}"
    local FLAG_QUIET="$( echo "${2-}" | tr '[:upper:]' '[:lower:]' )"

    if [ "${FLAG_QUIET}" == 'quiet' ]
    then
        REAL_PATH="$( cd "${REAL_PATH}" 2>/dev/null && pwd )" || return
    else
        REAL_PATH="$( cd "${REAL_PATH}" && pwd )" || return
    fi
    echo "${REAL_PATH}"
}
