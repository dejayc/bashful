#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Requires:
#   bashful.inc.sh
#   bashful-litest.inc.sh
#   bashful-list.inc.sh
#   bashful-seq.inc.sh

source "${0%/*}/../bashful.inc.sh" || exit
source "${BASHFUL_PATH}/bashful-list.inc.sh" || exit
source "${BASHFUL_PATH}/bashful-seq.inc.sh" || exit
source "${BASHFUL_PATH}/bashful-litest.inc.sh" || exit

declare NL=$'\n'

function testSpec_intseq()
{
    TEST_CASE="${1}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="intSeq 2 4 6 10-08"
        OUT='2 4 6 10 09 08'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="intSeq -u 5-8 10-6"
        OUT='5 6 7 8 10 9'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="intSeq -s ':' 1-5"
        OUT='1:2:3:4:5'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="intSeq -s ',' '1' '2' '' '4' '5' '' '6'"
        OUT='1,2,4,5,6'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="intSeq -s ',' -n '1' '2' '' '4' '5' '' '6'"
        OUT='1,2,,4,5,,6'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="intSeq -s ',' -n -u '1' '2' '' '4' '5' '' '6'"
        OUT='1,2,,4,5,6'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Multiple args; ranges; padding'
        CMD="intSeq '2 - 6' ' 1' ' 2  ' '  0-7 ' ' 4 ' 3 '05-10'"
        OUT='2 3 4 5 6 1 2 0 1 2 3 4 5 6 7 4 3 05 06 07 08 09 10'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Multiple args; ranges; padding; unique'
        CMD="intSeq -u '2 - 6' ' 1' ' 2  ' '  0-7 ' ' 4 ' 3 '05-10'"
        OUT='2 3 4 5 6 1 0 7 05 06 07 08 09 10'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Multiple args with padding and newlines'
        CMD="intSeq '1${NL}' ' 2${NL} ' 3 '4${NL}'"
        OUT='1 2 3 4'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Invalid characters'
        CMD="intSeq 1 a 3"
        OUT=''
        let STAT=1
        ;;
    all)
        _iterateTo ${I}
        ;;
    *)
        return 1
        ;;
    esac

    TEST_DESC="${DESC}"
    TEST_CMD="${CMD}"
    TEST_EXP_OUTPUT="${OUT}"
    let TEST_EXP_STATUS=${STAT}
    return 0
}

executeLitest "${@}"
