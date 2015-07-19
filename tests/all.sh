#!/bin/bash

declare TEST_DIR="${BASH_SOURCE[0]%/*}"

cd "${TEST_DIR}" || {

    echo "ERROR: Couldn't enter test directory"
    echo "DIRECTORY: ${TEST_DIR}"
    exit 1
}

./text.sh all && \
./list.sh all && \
./match.sh all && \
./seq.sh all && \
./sshs.sh all
