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

arrayToCommaSeparatedList() {
    local AT_FIRST=1

    for arg in "${@}"
    do
        if [[ ${AT_FIRST} -eq 1 ]]
        then
            LIST="${arg}"
            let AT_FIRST=0
        else
            LIST="${LIST}, ${arg}"
        fi
    done
    echo "${LIST}"

    return ${#@}
}

escapeRegex() {
    echo "${1}" | sed 's/\([[:punct:]]\)/[\1]/g'
}

macroArrayFromLines() {
cat <<:END_DECLARE
    NAME_OF_LINES_VAR="${1##[$]}"
    NAME_OF_ARRAY_VAR="${2##[$]}"
    PRESERVE_EMPTY_LINES=$( parseBoolean "${3}" )
:END_DECLARE
cat <<':END_MACRO'
    declare -a "${NAME_OF_ARRAY_VAR}"
    let INDEX=0

    while read -r LINE
    do
        [[ "${LINE}" != '' ]] || {
            [[ ${PRESERVE_EMPTY_LINES} -eq 0 ]] && continue
        }

        eval "${NAME_OF_ARRAY_VAR}[INDEX++]=\"\${LINE}\""
    done < <( echo -e "${!NAME_OF_LINES_VAR}" )
:END_MACRO
}

macroLinesFromArray() {
cat <<:END_DECLARE
    NAME_OF_ARRAY_VAR="${1##[$]}[@]"
    NAME_OF_LINES_VAR="${2##[$]}"
:END_DECLARE
cat <<':END_MACRO'
    eval "${NAME_OF_LINES_VAR}=''"

    for line in "${!NAME_OF_ARRAY_VAR}"
    do
        eval "${NAME_OF_LINES_VAR}=\"\${${NAME_OF_LINES_VAR}}\${line}
\""
    done

    eval "${NAME_OF_LINES_VAR}=\"\${${NAME_OF_LINES_VAR}%%
}\""
:END_MACRO
}

parseBoolean() {
    testBoolean "${1}"
    echo $(( ! ${?} ))
}

testBoolean() {
    local INPUT=$( echo "${1}" | tr '[a-z]' '[A-Z]' )

    [[ "${INPUT}" =~ ^[-+]?[0-9]+$ ]] && {
        [[ "${INPUT}" -gt 0 ]] && return 0
        return 1
    }

    [[ "${INPUT}" == 'TRUE' || \
       "${INPUT}" == 'Y' || "${INPUT}" == 'YES' ]] && return 0

    return 1
}
