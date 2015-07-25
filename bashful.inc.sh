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
    declare BASHFUL_LOADED_bashful='bashful'

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

# Returns true if the current debugging level is greater than or equal to the
# specified debugging level.
function ifDebug()
{
    local REQUIRED_DEBUG_LEVEL="${1-1}"

    [[ "${SCRIPT_DEBUG_LEVEL-0}" -ge ${REQUIRED_DEBUG_LEVEL} ]]
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

function isModuleLoaded()
{
    local MODULE="${1-}"
    [[ -z "${MODULE}" ]] || isVariableSet "BASHFUL_LOADED_${MODULE}"
}

function isScriptInteractive()
{
    [[ "${-}" =~ 'i' ]]
}

function isScriptSourced()
{
    [[ "${BASH_ARGV}" != '' ]]
}

function isScriptSshCommand()
{
    [[ "$(ps -o comm= -p $PPID)" =~ 'sshd' ]]
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

# If debugging is enabled, output the specified text to STDERR.
function stderr_ifDebug()
{
    declare -i STATUS_CODE="${2-${?}}"
    local REQUIRED_DEBUG_LEVEL="${1-1}"

    [[ "${SCRIPT_DEBUG_LEVEL-0}" -ge ${REQUIRED_DEBUG_LEVEL} ]] && \
        stderr ${STATUS_CODE}
}

function stdout()
{
    local LINE
    IFS='' read -r -d '' LINE
    echo -n "${LINE}"
}

# If debugging is enabled, output the specified text to STDOUT.
function stdout_ifDebug()
{
    local REQUIRED_DEBUG_LEVEL="${1-1}"

    [[ "${SCRIPT_DEBUG_LEVEL-0}" -ge ${REQUIRED_DEBUG_LEVEL} ]] && stdout
}

# Verifies that all required module dependencies are loaded, or generates an
# error otherwise.
function verifyBashfulDependencies()
{
    local VAR_LIST="$( compgen -v )"
    declare -a MODULES=()

    while [[ "${VAR_LIST}" =~ \
(^|[[:space:]])BASHFUL_LOADED_([^[:space:]]+)(.*)$ ]]
    do
        MODULES[${#MODULES[@]}]="${BASH_REMATCH[2]}"
        VAR_LIST="${BASH_REMATCH[3]}"
    done

    declare -i MODULE_LEN=${#MODULES[@]}
    declare -i I=0
    declare -i MODULE_MISSING=0

    while [ ${I} -lt ${MODULE_LEN} ]
    do
        local MODULE="${MODULES[I]}"
        let I++ ||:

        local DEPS_VAR="BASHFUL_DEPS_${MODULE}"
        isVariableSet "${DEPS_VAR}" || continue

        unset DEPS
        declare -a DEPS="( ${!DEPS_VAR} )"
        declare -i DEPS_LEN=${#DEPS[@]}
        declare -i J=0

        while [ ${J} -lt ${DEPS_LEN} ]
        do
            local DEP="${DEPS[J]}"
            let J++ ||:

            isModuleLoaded "${DEP}" || {

                let MODULE_MISSING=1
                echo \
"Bashful module '${MODULE}' requires missing module '${DEP}'" | stderr
            }
        done
    done

    return ${MODULE_MISSING}
}
