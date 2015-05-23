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

[[ "${HOME_DIR_ROOT}" != '' ]] || HOME_DIR_ROOT='/home'
[[ "${ROOT_HOME_DIR}" != '' ]] || ROOT_HOME_DIR='/root'

doesDirExist() {
    local DIR_NAME="${1}"
    [[ -d "${DIR_NAME}" ]] && return 0
    return 1
}

doesUserExist() {
    local USER_NAME="${1}"
    id "${USER_NAME}" 1>/dev/null 2>&1
    return ${?}
}

findLatestMatchingFile() {
    findMatchingFiles "${@}" | head -n 1
}

findMatchingFiles() {
    local FILE_MATCH_REGEX="${1}"
    local PATH_LIST=$( normalizePath "${2}" )

    for path in "${@:3}"
    do
        path=$( normalizePath "${path}" )
        [[ "${path}" != '' ]] || continue
        PATH_LIST="${PATH_LIST}\n${path}"
    done

    eval "$( macroArrayFromLines PATH_LIST PATHS )"

    find $( echo -e "${PATHS[@]}" ) \
        -maxdepth 1 -type f -exec ls -t1 '{}' + 2>/dev/null \
        | grep -E "${FILE_MATCH_REGEX}"
}

findOldestMatchingFile() {
    findMatchingFiles "${@}" | tail -n 1
}

getCanonicalPath() {
    local PATH_IN="${1}"

    pushd "${PATH_IN}" >/dev/null
    pwd
    popd >/dev/null
}

getUserHomeDir() {
    local USER_NAME="${1}"

    if [[ "${USER_NAME}" == 'root' ]]
    then
        echo "${ROOT_HOME_DIR}"
    else
        normalizeFilePath "${HOME_DIR_ROOT}" "${USER_NAME}"
    fi
}

macroFileListFromArray() {
cat <<:END_DECLARE
    NAME_OF_ARRAY_VAR="${1##[$]}[@]"
    NAME_OF_LIST_VAR="${2##[$]}"
    REMOVE_LEADING_SLASH=$( parseBoolean "${3}" )
:END_DECLARE
cat <<':END_MACRO'
    eval "${NAME_OF_LIST_VAR}=''"

    for file in "${!NAME_OF_ARRAY_VAR}"
    do
        file=$( normalizePath "${file}" ${REMOVE_LEADING_SLASH} )
        [[ "${file}" != '' ]] || continue
        eval "${NAME_OF_LIST_VAR}=\"\${${NAME_OF_LIST_VAR}}\${file}
\""
    done
:END_MACRO
}

normalizeFilePath() {
    local REMOVE_LEADING_SLASH=$( parseBoolean "${3}" )
    local PATH_IN=$( normalizePath "${1}" ${REMOVE_LEADING_SLASH} )
    local FILE_IN="${2}"

    [[ "${PATH_IN}" == '/' ]] && {
        echo "/${FILE_IN}"
        return
    }

    [[ "${PATH_IN}" != '' ]] || {
        PATH_IN='.'
    }

    echo "${PATH_IN}/${FILE_IN}"
}

normalizePath() {
    local PATH_IN="${1}"
    local REMOVE_LEADING_SLASH=$( parseBoolean "${2}" )

    if [[ ${REMOVE_LEADING_SLASH} -ne 0 ]]
    then
        echo "${PATH_IN}" | sed \
            -e 's/[/]\+/\//g' -e 's/\([^/]\)[/]$/\1/' -e 's/^[/]//'
    else
        echo "${PATH_IN}" | sed \
            -e 's/[/]\+/\//g' -e 's/\([^/]\)[/]$/\1/'
    fi
}

normalizePathList() {
    local PATH_LIST="${1}"
    local REMOVE_LEADING_SLASH=$( parseBoolean "${2}" )

    while read -r PATH_IN
    do
        normalizePath "${PATH_IN}" ${REMOVE_LEADING_SLASH}
        [[ "${NORMALIZED_PATH}" != '' ]] && echo "${NORMALIZED_PATH}"
    done < <( echo "${PATH_LIST}" )
}

removeExcessMatchingFile() {
    local FILE_MATCH_REGEX="${1}"
    local FILE_PATH="${2}"
    local MAX_FILES="${3}"

    [[ "${MAX_FILES}" -gt 0 ]] || return 0

    local MATCHING_FILES=$(
        findMatchingFiles "${FILE_MATCH_REGEX}" "${FILE_PATH}" )

    local MATCHING_FILE_COUNT=$( echo -e "${MATCHING_FILES}" | wc -l )

    [[ "${MAX_FILES}" -ge "${MATCHING_FILE_COUNT}" ]] && return 0

    # Instead of risking automated deletion of too many files, only one file
    # will be deleted if the number of files exceeds the specified max allowed
    # number of files.  This strategy allows disk space to be reclaimed in
    # response to creation of a new files (for example, when rotating logs),
    # without unintentionally deleting too many files in the event that the
    # specified max allowed number of files is misconfigured.

    local FILE_TO_REMOVE=$( echo -e "${MATCHING_FILES}" | tail -n 1 )

    [[ "${FILE_TO_REMOVE}" != '' ]] && {
        notify "Removing extraneous file '${FILE_TO_REMOVE}'"

        rm "${FILE_TO_REMOVE}"
        onError ${?}
    }
}

removeFileIfIdentical() {
    local FILE_TO_REMOVE="${1}"
    local FILE_TO_COMPARE="${2}"

    cmp -s "${FILE_TO_REMOVE}" "${FILE_TO_COMPARE}"

    case ${?} in
    0)
        rm "${FILE_TO_REMOVE}"
        return 0
        ;;

    1)
        return 1
        ;;

    *)
        return 2
        ;;
    esac
}
