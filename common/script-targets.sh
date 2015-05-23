#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause
#
# Excerpts copied from bash-script-lib, copyright 2009-2011 Dejay Clayton:
#     http://sourceforge.net/projects/bash-script-lib/
# bash-script-lib is licensed under the Apache License Version 2.0:
#     http://www.apache.org/licenses/LICENSE-2.0

executeTarget() {
    local TARGET=$(
        echo "${1}" | tr [:upper:] [:lower:] | sed 's/[^a-zA-Z0-9_]/_/g' )

    local ARG_CMD=''
    for arg in "${@:2}"
    do
        ARG_CMD="${ARG_CMD} '${arg}'"
    done

    {
        eval "executeTarget_${TARGET}" "${ARG_CMD}"
    } 2>&1
}

executeTargets() {
    [[ ${#@} -gt 0 ]] || exitShowUsage

    validateTargetNames "${@}"
    local INVALID_ARG=${?}
    [[ ${INVALID_ARG} -eq 0 ]] || handleInvalidTarget "${@:${INVALID_ARG}:1}"

    validateUser "${REQUIRED_USER}"

    [[ ${HAS_TERMINAL} -eq 1 ]] && {
        confirmTargets $(
            arrayToCommaSeparatedList "${@}" | tr [:upper:] [:lower:] )

        [[ ${?} -eq 0 ]] || exit 1
    }

    for arg in "${@}"
    do
        executeTarget "${arg}"
    done
}

showTargetUsage() {
    local USAGE_SYNOPSIS="${1}"
    local PRIMARY_TARGET_LIST_DESC="${2}"
    local SECONDARY_TARGET_LIST_DESC="${3}"

    declare -a PRIMARY_TARGETS
    declare -a SECONDARY_TARGETS
    declare -a HIDDEN_TARGETS

    for target in "${VALID_TARGETS[@]}"
    do
        local INDEX
        if [[ "${target%%[+]}" != "${target}" ]]
        then
            let INDEX=${#PRIMARY_TARGETS[@]}
            PRIMARY_TARGETS[$INDEX]="${target%%[+]}"
        elif [[ "${target%%[-]}" == "${target}" ]]
        then
            let INDEX=${#SECONDARY_TARGETS[@]}
            SECONDARY_TARGETS[$INDEX]="${target}"
        else
            let INDEX=${#HIDDEN_TARGETS[@]}
            HIDDEN_TARGETS[$INDEX]="${target}"
        fi
    done

    echo
    echo "${USAGE_SYNOPSIS}"
    echo
    echo "${PRIMARY_TARGET_LIST_DESC}"
    tabulateArray 3 '   ' "${PRIMARY_TARGETS[@]}"

    [[ ${#SECONDARY_TARGETS[@]} -gt 0 ]] && {
        echo
        echo "${SECONDARY_TARGET_LIST_DESC}"
        tabulateArray 3 '   ' "${SECONDARY_TARGETS[@]}"
    }
}

validateTargetNames() {
    [[ ${#@} -gt 0 ]] || return 0

    local CURRENT_ARG=0
    for arg in "${@}"
    do
        let CURRENT_ARG++
        arg=$( echo "${arg}" | sed 's/\s//g' | tr [:upper:] [:lower:] )

        local IS_VALID=0
        for target in "${VALID_TARGETS[@]}"
        do
            [[ "${arg}" == "${target%[+-]}" ]] && {
               IS_VALID=1
               break
            }
        done

        [[ ${IS_VALID} -eq 1 ]] || return ${CURRENT_ARG}
    done
    return 0
}

validateUser() {
    local REQUIRED_USER="${1}"
    local SCRIPT_USER=`whoami`

    [[ "${REQUIRED_USER}" == '' || \
         "${REQUIRED_USER}" == "${SCRIPT_USER}" ]] || \
    {
        notify "ERROR: This script must be run as '${REQUIRED_USER}'"
        return 1
    }
    return 0
}
