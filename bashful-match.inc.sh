#!/bin/bash

# Bashful is copyright 2009-2016 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Declare the module name and dependencies.
declare BASHFUL_MODULE='match'
declare BASHFUL_MODULE_DEPENDENCIES='list text'

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

    # Register the module and dependencies.
    declare "${BASHFUL_MODULE_VAR}"="${BASHFUL_MODULE}"
    declare "BASHFUL_DEPS_${BASHFUL_MODULE}"="${BASHFUL_MODULE_DEPENDENCIES}"
}

# function ifWildcardMatches
#
# Returns status 0 if the second passed parameter, when interpreted as a
# wildcard, matches the first passed parameter.  Otherwise, returns 1.
# Wildcard characters asterisk '*' and question mark '?' are treated as
# special wildcard characters, with '*' matching any sequence of characters,
# and '?' matching any single character.  All other characters are treated as
# literal characters.
#
# Examples:
#
# $ ifWildcardMatches 'tortoise' 'tortoise'; echo ${?}
# 0
#
# $ ifWildcardMatches 'tortoise' 'porpoise'; echo ${?}
# 1
#
# $ ifWildcardMatches 'tortoise' '?or?oise'; echo ${?}
# 0
#
# $ ifWildcardMatches 'tortoise' '*oise'; echo ${?}
# 0
#
# $ ifWildcardMatches 'tortoise' 'tort'; echo ${?}
# 1
function ifWildcardMatches()
{
    local VALUE="${1-}"
    local PATTERN="${2-}"

    [[ "${VALUE}" == "${PATTERN}" ]] && return 0

    PATTERN="$( escapedExtendedRegex "${PATTERN}" )" || return
    PATTERN="${PATTERN//\\[*]/.*}"
    PATTERN="${PATTERN//\\[?]/.}"

    [[ "${VALUE}" =~ ^${PATTERN}$ ]]
}

# function valueForMatchedName
#
# Accepts a name as the first argument, and any number of name/value pairs as
# subsequent arguments, and returns the value of the first name/value pair
# that matches the specified name.  If no match is found, returns the status
# code 1.
#
# -l optionally returns the value of the last name/value pair that matches the
#    specified name.  By default, the value of the first name/value pair that
#    matches the specified name is returned.
#
# -d optionally specifies one or more value delimiter characters.  The first
#    occurrence of an input delimiter within a name/value pair will be used to
#    split the name and value.  All subsequent occurrences will be considered
#    part of the value.  Defaults to '='.  An error is returned if null.
#
# -t optionally trims leading and trailing whitespace from the name, and each
#    name and value in name/value pairs.
#
# -v optionally treats arguments without an input delimiter as a value with a
#    null name.  By default, such entries are treated as a name with a null
#    value.
#
# -w optionally performs wildcard matching, interpreting the name within each
#    name/value pair as a wildcard against which to compare the name argument.
#
# Examples:
#
# $ valueForMatchedName '3' '1=a' '2=b' '3=c'
# c
#
# $ valueForMatchedName -w 'book' 'b*=1' 'bo*=2' 'b?o*=3'
# 1
#
# $ valueForMatchedName -w 'book' 'b* = 1' 'bo*=2'
# 2
#
# $ valueForMatchedName -t -w '  book  ' 'b* = 1' 'bo*=2'
# 1
#
# $ valueForMatchedName -w -l 'book' 'b*=1' 'bo*=2' 'b?o*=3'
# 3
#
# $ valueForMatchedName '' 'empty' '=value'
# value
#
# $ valueForMatchedName -v '' 'empty' '=value'
# empty
function valueForMatchedName()
{
    local DELIM='='
    declare -i REPORT_LAST_MATCH=0
    declare -i SINGLE_IS_VALUE=0
    declare -i TRIM_TEXT=0
    declare -i WILDCARD_MATCHES=0

    # Parse function options.
    declare -i OPTIND
    local OPT=''

    while getopts ":d:lvtw" OPT
    do
        case "${OPT}" in
        d)
            DELIM="${OPTARG}"
            [[ -z "${DELIM}" ]] && return 1
            ;;
        l)
            let REPORT_LAST_MATCH=1
            ;;
        t)
            let TRIM_TEXT=1
            ;;
        v)
            let SINGLE_IS_VALUE=1
            ;;
        w)
            let WILDCARD_MATCHES=1
            ;;
        *)
            return 2
        esac
    done
    shift $(( OPTIND - 1 ))
    # Done parsing function options.

    local NAME="${1-}"
    shift ||:

    [[ ${TRIM_TEXT} -eq 0 ]] || {

        NAME="${NAME#"${NAME%%[![:space:]]*}"}"
        NAME="${NAME%"${NAME##*[![:space:]]}"}"
    }

    declare -i FOUND_MATCH=0
    local MATCH=''

    while [ $# -gt 0 ]
    do
        local PAIR_STR="${1}"
        shift

        local PAIR_LIST
        PAIR_LIST="$( splitList -d "${DELIM}" "${PAIR_STR}" )" || return

        unset PAIR
        declare -a PAIR=() # Compatibility fix.
        declare -a PAIR="( ${PAIR_LIST} )" || return
        declare -i PAIR_LEN=${#PAIR[@]-}

        local PATTERN=''
        local VALUE=''

        case ${PAIR_LEN} in
        1)
            if [ ${SINGLE_IS_VALUE} -ne 0 ]
            then
                VALUE="${PAIR[0]}"
            else
                PATTERN="${PAIR[0]}"
            fi
            ;;
        2)
            PATTERN="${PAIR[0]}"
            VALUE="${PAIR[1]}"
            ;;
        *)
            PATTERN="${PAIR[0]}"
            VALUE="${PAIR_STR:$(( ${#PATTERN} + 1 ))}"
            ;;
        esac

        [[ ${TRIM_TEXT} -eq 0 ]] || {

            PATTERN="${PATTERN#"${PATTERN%%[![:space:]]*}"}"
            PATTERN="${PATTERN%"${PATTERN##*[![:space:]]}"}"

            VALUE="${VALUE#"${VALUE%%[![:space:]]*}"}"
            VALUE="${VALUE%"${VALUE##*[![:space:]]}"}"
        }

        declare -i IS_MATCHING=0

        if [ ${WILDCARD_MATCHES} -ne 0 ]
        then
            ifWildcardMatches "${NAME}" "${PATTERN}" && let IS_MATCHING=1
        else
            [[ "${NAME}" == "${PATTERN}" ]] && let IS_MATCHING=1
        fi

        [[ ${IS_MATCHING} -eq 0 ]] || {

            let FOUND_MATCH=1
            MATCH="${VALUE}"
            [[ ${REPORT_LAST_MATCH} -eq 0 ]] && break
        }
    done
    echo -n "${MATCH}"
    [[ ${FOUND_MATCH} -ne 0 ]]
}
