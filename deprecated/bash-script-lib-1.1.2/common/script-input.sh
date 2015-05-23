#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause
#
# Excerpts copied from bash-script-lib, copyright 2009-2015 Dejay Clayton:
#     http://sourceforge.net/projects/bash-script-lib/
# bash-script-lib is licensed under the Apache License Version 2.0:
#     http://www.apache.org/licenses/LICENSE-2.0

readFile() {
    local FILE_NAME="${1}"

    if [[ "${FILE_NAME}" != "${FILE_NAME%.bz2}" ]]
    then
        bzip2 -d -c "${FILE_NAME}"
    else
        cat "${FILE_NAME}"
    fi
}

processFiles() {
    declare -a FILE_NAMES=( "${@}" )

    for fileName in "${FILE_NAMES[@]}"
    do
        readFile "${fileName}" | processInput "${fileName}"
    done
}

execute() {
    if tty -s
    then
        local HAS_TERMINAL=1
    else
        local HAS_TERMINAL=0
    fi

    [[ ${HAS_TERMINAL} -eq 0 || "${1}" != '' ]] || {
        showUsage
        exit 1
    }

    preProcess

    (
        if [[ ${HAS_TERMINAL} -eq 1 ]]
        then
            processFiles "${@}"
        else
            processFiles '-' "${@}"
        fi
    ) | processOutput

    postProcess
}
