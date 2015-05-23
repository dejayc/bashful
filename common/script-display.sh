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

if tty -s
then
    HAS_TERMINAL=1
else
    HAS_TERMINAL=0
fi

if [[ "${-}" =~ 'i' ]]
then
    IS_INTERACTIVE=1
else
    IS_INTERACTIVE=0
fi

confirm() {
    local PROMPT="${1}"
    read -p "${PROMPT}" CHOICE
    CHOICE=$( echo "${CHOICE}" | sed 's/\s//g' | tr [:upper:] [:lower:] )

    [[ "${CHOICE}" == 'y' || "${CHOICE}" == 'yes' ]] && return 0
    return 1
}

macroPrintArray() {
cat <<:END_DECLARE
    NAME_OF_ARRAY_VAR="${1##[$]}"
:END_DECLARE
cat <<':END_MACRO'
    if [[ "${NAME_OF_ARRAY_VAR}" == '@' ]]
    then
        declare -a ARRAY_COPY=( "${@}" )
    else
        REF_OF_ARRAY_VAR="${NAME_OF_ARRAY_VAR}[@]"
        declare -a ARRAY_COPY=( "${!REF_OF_ARRAY_VAR}" )
    fi
    let INDEX=0
    while [[ ${INDEX} -lt ${#ARRAY_COPY[@]} ]]
    do
        echo "${NAME_OF_ARRAY_VAR}[${INDEX}]=[${ARRAY_COPY[INDEX]}]"
        let INDEX++
    done
:END_MACRO
}

notify() {
    local MESSAGE="${1}"
    echo -e "${MESSAGE}"
}

onError() {
    local STATUS="${1}"

    [[ "${STATUS}" -eq 0 ]] || {
        echo
        echo 'ERROR: A failure occurred while performing a required operation.'
        exit "${STATUS}"
    }
}

tabulateArray() {
    local COLUMNS="${1}"
    local INDENT="${2}"
    declare -a CONTENTS=( "${@:3}" )

    local COUNT=0
    local LINE=''
    ( for cell in "${CONTENTS[@]}"
    do
        [[ ${COUNT} -eq ${COLUMNS} ]] && {
            echo "${LINE}"
            LINE=''
            COUNT=0
        }

        if [[ "${LINE}" != '' ]]
        then
            LINE="${LINE} ${cell}"
        else
            LINE="${cell}"
        fi
        let COUNT++
    done

    [[ "${LINE}" != '' ]] && echo "${LINE}"

    ) | column -t | sed "s/^/${INDENT}/"
}
