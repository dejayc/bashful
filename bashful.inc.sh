#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Verify caller context.
[[ "${BASH_ARGV}" != '' ]] || {
    echo "ERROR: ${BASH_SOURCE[0]##*/} must be sourced, not executed"
    exit 1
} >&2

# Exit if Bashful was previously included.
[[ -z "${BASHFUL_VERSION:-}" ]] || return 0

# Initialize global variables.
{
    # Bashful information.
    declare BASHFUL_VERSION='1.0'

    # Script information.
    declare BASHFUL_PATH="${BASH_SOURCE[0]}"
    if [[ "${BASHFUL_PATH}" =~ / ]]
    then
        BASHFUL_PATH="$( cd "${BASHFUL_PATH%/*}" && pwd )"
    else
        BASHFUL_PATH="$( pwd )"
    fi

    declare SCRIPT_INVOKED_NAME="${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}"
    declare SCRIPT_NAME="${SCRIPT_INVOKED_NAME##*/}"
    declare SCRIPT_INVOKED_PATH="$( dirname "${SCRIPT_INVOKED_NAME}" )"
    declare SCRIPT_PATH="$( cd "${SCRIPT_INVOKED_PATH}"; pwd )"
    declare SCRIPT_RUN_DATE="$( date )"

    # Script debugging level.
    declare -i SCRIPT_DEBUG_LEVEL=0
}

# If debugging is enabled, output the specified text to STDERR.
function ifDebug_stderr()
{
    declare -i STATUS_CODE="${2-${?}}"
    local REQUIRED_DEBUG_LEVEL="${1-1}"

    [[ "${SCRIPT_DEBUG_LEVEL-0}" -ge ${REQUIRED_DEBUG_LEVEL} ]] && \
        stderr ${STATUS_CODE}
}

# If debugging is enabled, output the specified text to STDOUT.
function ifDebug_stdout()
{
    local REQUIRED_DEBUG_LEVEL="${1-1}"

    [[ "${SCRIPT_DEBUG_LEVEL-0}" -ge ${REQUIRED_DEBUG_LEVEL} ]] && stdout
}

function indexOf()
{
    local FIND="${1-}"

    declare -i I=2
    declare -i N=${#@}

    while [ ${I} -le ${N} ]
    do
        [[ "${!I}" == "${FIND}" ]] && {

            echo -n $(( I - 2 ))
            return
        }
        let I+=1
    done
    false
}

function isFunction()
{
    local FUNCTION_NAME="${1-}"
    [[ -n "${FUNCTION_NAME}" ]] && declare -f "${FUNCTION_NAME}" > /dev/null
}

function isScriptInteractive()
{
    [[ "${-}" =~ 'i' ]]
}

function isScriptSourced()
{
    [[ "${BASH_ARGV}" != '' ]]
}

function isVariableSet()
{
    local VAR_NAME="${1-}"
    [[ -n "${VAR_NAME}" && ! -z "${!VAR_NAME+x}" ]];
}

function stderr()
{
    declare -i ERR_CODE="${1-$(( ${?} > 0 ? ${?} : 2 ))}"
    stdout >&2
    return ${ERR_CODE}
}

function stdout()
{
    local LINE
    IFS='' read -r -d '' LINE
    echo -n "${LINE}"
}

# Accepts a Bashful module name and a list of module dependencies, and
# generates an error and non-zero status code if one or more dependencies are
# not already loaded.
function verifyModules()
{
    local MODULE="${1?'INTERNAL ERROR: Module not specified'}"
    shift

    declare -a MISSING=()

    while [ $# -gt 0 ]
    do
        local DEPENDENCY="${1}"
        shift

        [[ -n "${DEPENDENCY}" ]] || continue

        isVariableSet "BASHFUL_LOADED_${DEPENDENCY}" && continue
        MISSING[${#MISSING[@]}]="${DEPENDENCY}"
    done

    if [ ${#MISSING[@]} -gt 0 ]
    then
        {
            echo "ERROR: Aborting loading of Bashful module '${MODULE}'"
            printf "Required Bashful module '%s' is not loaded\n" \
                "${MISSING[@]}"
        } | stderr
        return 1
    fi
}
