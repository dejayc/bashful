#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Declare the module name and dependencies.
declare BASHFUL_MODULE='error'

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

    # Ensure Bashful is loaded.
    [[ -n "${BASHFUL_VERSION}" ]] || {
        echo "ERROR: Aborting loading of Bashful module '${BASHFUL_MODULE}'"
        echo "Dependency 'bashful.inc.sh' is not loaded"
        [[ "${BASH_ARGV}" != '' ]] || exit 2; return 2;
    } >&2

    # Register the module.
    declare "${BASHFUL_MODULE_VAR}"="${BASHFUL_MODULE}"
}

# Bashful error code ranges:
#         0: Success
#         1: General script error
#         2: Usage error or help; or error executing built-in command
#   3 -  19: Error codes returned from utilities and shell
#  20 -  39: A user-supplied parameter was missing
#  40 -  59: A user-supplied parameter was invalid
#  60 -  79: A script-supplied parameter was missing
#  80 -  99: A script-supplied parameter was invalid
# 100 - 119: A resource specified by a parameter was inaccessible
# 120 - 139: Reserved for special shell exit codes
#       126: A command was not executable, due to permission or file issues
# 140 - 159: A configuration setting was missing
# 160 - 179: A configuration setting was invalid
# 180 - 199: A resource specified by a configuration setting was inaccessible
# 200 - 219: An internal script error occurred

# Default bash error codes:
# (please refer to http://www.tldp.org/LDP/abs/html/exitcodes.html)
#         0: Success
#         1: General script error
#         2: Usage error or help; or error executing built-in command
#       126: A command was not executable, due to permission or file issues
#       127: An illegal command was specified
#       128: Exit status was out of range
# 128 - 255: An error signal of (128 + n) was encountered. E.g. kill -9 = 137
#       130: Execution was terminated via Ctrl-C (128 + 2)
#       255: Exit status was out of range

function ERROR_commandExecution()
{
    declare -i STATUS=${?}
    declare -i ERR_CODE=3

    if [ -n "${2-}" ]
    then
        let ERR_CODE="${2}"
    else
        [[ ${STATUS} -ne 0 ]] && let ERR_CODE=STATUS
    fi

    local COMMAND="${1?'INTERNAL ERROR: Command not specified'}"

    stderr ${ERR_CODE} <<:ERROR
ERROR: A command encountered an error during execution
COMMAND: ${COMMAND}
ERROR CODE: ${ERR_CODE}
:ERROR
}

function ERROR_commandNotExecutable()
{
    declare -i STATUS=${?}
    declare -i ERR_CODE=126

    if [ -n "${2-}" ]
    then
        let ERR_CODE="${2}"
    else
        [[ ${STATUS} -ne 0 ]] && let ERR_CODE=STATUS
    fi

    local COMMAND="${1?'INTERNAL ERROR: Command not specified'}"

    stderr ${ERR_CODE} <<:ERROR
ERROR: A required command was not executable
COMMAND: ${COMMAND}
:ERROR
}

function ERROR_invalidSettingValue()
{
    declare -i STATUS=${?}
    declare -i ERR_CODE=160

    if [ -n "${3-}" ]
    then
        let ERR_CODE="${3}"
    else
        [[ ${STATUS} -ne 0 ]] && let ERR_CODE=STATUS
    fi

    local SETTING_NAME="${1?'INTERNAL ERROR: Setting not specified'}"
    local SETTING_VALUE="${2-}"

    stderr ${ERR_CODE} <<:ERROR
ERROR: An invalid value was specified for a required script setting
SETTING: ${SETTING_NAME}
VALUE: ${SETTING_VALUE}
:ERROR
}

function ERROR_missingSetting()
{
    declare -i STATUS=${?}
    declare -i ERR_CODE=140

    if [ -n "${2-}" ]
    then
        let ERR_CODE="${2}"
    else
        [[ ${STATUS} -ne 0 ]] && let ERR_CODE=STATUS
    fi

    local SETTING_NAME="${1?'INTERNAL ERROR: Setting not specified'}"

    stderr ${ERR_CODE} <<:ERROR
ERROR: A required script setting was missing
SETTING: ${SETTING_NAME}
:ERROR
}
