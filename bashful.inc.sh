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
    local FIND="${1}"

    declare -i I=2
    declare -i N=${#@}

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
    local FUNCTION_NAME="${1}"
    declare -f "${FUNCTION_NAME}" > /dev/null
}

function isVariableSet()
{
    local VAR_NAME="${1}"

    [[ ! -z "${!VAR_NAME+x}" ]];
}

# Show an error if a command-line utility encountered an error being executed.
function showErrorCommandExecutionError()
{
    local COMMAND="${1}"
    local ERR_CODE="${2}"

    {
        cat <<:ERROR
ERROR: A command encountered an error during execution
COMMAND: ${COMMAND}
ERROR CODE: ${ERR_CODE}
:ERROR
    } | stderr "${ERR_CODE:-2}" || return
}

# Show an error if a required command-line utility was not executable.
function showErrorCommandNotExecutable()
{
    local COMMAND="${1}"
    local ERR_CODE="${2}"

    {
        cat <<:ERROR
ERROR: A required command was not executable
COMMAND: ${COMMAND}
:ERROR
    } | stderr "${ERR_CODE:-2}" || return
}

# Show an error if a required script setting contains an invalid value.
function showErrorInvalidSettingValue()
{
    local SETTING_NAME="${1}"
    local SETTING_VALUE="${2}"
    local ERR_CODE="${3}"

    {
        cat <<:ERROR
ERROR: An invalid value was specified for a required script setting
SETTING: ${SETTING_NAME}
VALUE: ${SETTING_VALUE}
:ERROR
    } | stderr "${ERR_CODE:-2}" || return
}

# Show an error if a required script setting is missing or empty.
function showErrorMissingSetting()
{
    local SETTING_NAME="${1}"
    local ERR_CODE="${2}"

    {
        cat <<:ERROR
ERROR: A required script setting was missing
SETTING: ${SETTING_NAME}
:ERROR
    } | stderr "${ERR_CODE:-2}" || return
}

function stderr()
{
    declare -i CURRENT_STATUS_CODE=${?}
    local STATUS_CODE="${1}"

    cat - 1>&2

    return "${STATUS_CODE:-$CURRENT_STATUS_CODE}"
}
