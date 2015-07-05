#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Requires:
#   No other bashful components are required.

# Exit if Bashful was previously included.
[[ "${BASHFUL_VERSION:-}" ]] && exit 0

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
}

function getBashfulVersion()
{
    return "${BASHFUL_VERSION}"
}

function indexOf()
{
    local FIND="${1-}"

    declare -i I=2
    declare -i N=${#@-}

    while [ ${I} -le ${N} ]
    do
        [[ "${!I}" == "${FIND}" ]] && {

            echo $(( I - 2 ))
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

function isVariableSet()
{
    local VAR_NAME="${1-}"
    [[ -n "${VAR_NAME}" && ! -z "${!VAR_NAME+x}" ]];
}

# Show an error if a command-line utility encountered an error being executed.
function showErrorCommandExecutionError()
{
    declare -i ERR_CODE="${2-${?}}"
    local COMMAND="${1?'INTERNAL ERROR: Command not specified'}"

    stderr ${ERR_CODE} <<:ERROR || return
ERROR: A command encountered an error during execution
COMMAND: ${COMMAND}
ERROR CODE: ${ERR_CODE}
:ERROR
}

# Show an error if a required command-line utility was not executable.
function showErrorCommandNotExecutable()
{
    declare -i ERR_CODE="${2-${?}}"
    local COMMAND="${1?'INTERNAL ERROR: Command not specified'}"

    stderr ${ERR_CODE} <<:ERROR || return
ERROR: A required command was not executable
COMMAND: ${COMMAND}
:ERROR
}

# Show an error if a required script setting contains an invalid value.
function showErrorInvalidSettingValue()
{
    declare -i ERR_CODE="${3-${?}}"
    local SETTING_NAME="${1?'INTERNAL ERROR: Setting not specified'}"
    local SETTING_VALUE="${2-}"

    stderr ${ERR_CODE} <<:ERROR || return
ERROR: An invalid value was specified for a required script setting
SETTING: ${SETTING_NAME}
VALUE: ${SETTING_VALUE}
:ERROR
}

# Show an error if a required script setting is missing or empty.
function showErrorMissingSetting()
{
    declare -i ERR_CODE="${2-${?}}"
    local SETTING_NAME="${1?'INTERNAL ERROR: Setting not specified'}"

    stderr ${ERR_CODE} <<:ERROR || return
ERROR: A required script setting was missing
SETTING: ${SETTING_NAME}
:ERROR
}

function stderr()
{
    declare -i ERR_CODE="${1-$(( ${?} > 0 ? ${?} : 2 ))}"

    cat - 1>&2

    return ${ERR_CODE}
}
