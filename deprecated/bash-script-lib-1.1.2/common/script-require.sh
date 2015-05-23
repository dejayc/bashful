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

declare -a REQUIRED_FILES

checkRequiredFile() {
    local INCLUDE_FILE="${1}"

    for file in "${REQUIRED_FILES[@]}"
    do
        [[ "${file}" != "${INCLUDE_FILE}" ]] || return 0
    done
    return 1
}

registerRequiredFile() {
    local INCLUDE_FILE="${1}"

    checkRequiredFile "${INCLUDE_FILE}" && return 1

    local INDEX=${#REQUIRED_FILES[@]}
    REQUIRED_FILES[INDEX + 1]="${INCLUDE_FILE}"

    return 0
}
