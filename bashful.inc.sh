#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Requires:
#   No other bashful components are required.

# Initialize global variables.
{
    # Bashful information.
    declare    BASHFUL_VERSION='1.0'

    # Script information.
    declare    BASHFUL_PATH="$( dirname "${BASH_SOURCE[0]}" )"
    declare    BASHFUL_PATH="$( cd "${BASHFUL_PATH}" && pwd )"
    declare    SCRIPT_INVOKED_NAME="${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}"
    declare    SCRIPT_NAME="$( basename "${SCRIPT_INVOKED_NAME}" )"
    declare    SCRIPT_INVOKED_PATH="$( dirname "${SCRIPT_INVOKED_NAME}" )"
    declare    SCRIPT_PATH="$( cd "${SCRIPT_INVOKED_PATH}"; pwd )"
    declare    SCRIPT_RUN_DATE="$( date )"

    # Script debugging level.
    declare -i SCRIPT_DEBUG_LEVEL=0
}

function getBashfulVersion()
{
    return "${BASHFUL_VERSION}"
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
