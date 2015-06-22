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

function testSpec_perset()
{
    TEST_CASE="${1}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="permutedSet '1 2' 'a b'"
        OUT='1 a 1 b 2 a 2 b'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' '1,2' 'a,b'"
        OUT='1 a 1 b 2 a 2 b'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -i ':' -s ',' '1 2' 'a b'"
        OUT='1:a,1:b,2:a,2:b'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -i ':' -s ',' -S '1 2' 'a b'"
        OUT='1:a,1:b,2:a,2:b,'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' '1,,2' 'a,,b'"
        OUT='1 a,1 b,2 a,2 b'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' -n '1,,2' 'a,,b'"
        OUT='1 a,1,1 b,a,b,2 a,2,2 b'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' -p '1,,2' 'a,,b'"
        OUT='1 a,1,1 b,a,,b,2 a,2,2 b'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' -N -p '1,,2' 'a,,b'"
        OUT='1 a,1 ,1 b, a, , b,2 a,2 ,2 b'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' -n 'a big' 'bad,,' 'wolf'"
        OUT='a big bad wolf,a big wolf'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -n -q 'a big' 'bad,,' 'wolf'"
        OUT='a\ big\ bad\ wolf a\ big\ wolf'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' -n -q 'a big' 'bad,,' 'wolf'"
        OUT='a\ big\ bad\ wolf,a\ big\ wolf'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -i '' -s ',' -u '1,,2,,1' 'a,,b,,a'"
        OUT='1a,1b,2a,2b'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -i '' -s ',' -u -n '1,,2,,1' 'a,,b,,a'"
        OUT='1a,1,1b,a,b,2a,2,2b'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -i '' -s ',' -u -p '1,,2,,1' 'a,,b,,a'"
        OUT='1a,1,1b,a,,b,2a,2,2b'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='No args'
        CMD='permutedSet'
        OUT=''
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Null delimiter'
        CMD="permutedSet -d ''"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Multiple delimiters'
        CMD="permutedSet -d ',;' 'a,b;c'"
        OUT='a b c'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='One arg'
        CMD="permutedSet 'a b'"
        OUT='a b'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='One arg with null item separator'
        CMD="permutedSet -i '' 'a b'"
        OUT='a b'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='One arg with item separator'
        CMD="permutedSet -i ':' 'a b'"
        OUT='a b'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with null item separator'
        CMD="permutedSet -i '' 'a b' '1 2'"
        OUT='a1 a2 b1 b2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with item separator'
        CMD="permutedSet -i ':' 'a b' '1 2'"
        OUT='a:1 a:2 b:1 b:2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with null perm separator'
        CMD="permutedSet -s '' 'a b' '1 2'"
        OUT='a 1a 2b 1b 2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with perm separator'
        CMD="permutedSet -i '' -s ':' 'a b' '1 2'"
        OUT='a1:a2:b1:b2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='One arg with delimiter'
        CMD="permutedSet -d ',' 'a,b'"
        OUT='a b'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with delimiter'
        CMD="permutedSet -i '' -d ',' 'a,b' '1,2'"
        OUT='a1 a2 b1 b2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with preserved null perms'
        CMD="permutedSet -i '' -d ',' -p 'a,,b' '1,,2'"
        OUT='a1 a a2 1  2 b1 b b2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with preserved null items'
        CMD="permutedSet -i '' -d ',' -n 'a,,b' '1,,2'"
        OUT='a1 a a2 1 2 b1 b b2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with preserved null items'
        CMD="permutedSet -i ':' -s ',' -d ',' -n 'a,,b' '1,,2'"
        OUT='a:1,a,a:2,1,2,b:1,b,b:2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with preserved null items and seps'
        CMD="permutedSet -i ':' -s ',' -d ',' -n -N 'a,,b' '1,,2'"
        OUT='a:1,a:,a:2,:1,:2,b:1,b:,b:2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with preserved null items, perms, and seps'
        CMD="permutedSet -i ':' -s ',' -d ',' -n -N -p 'a,,b' '1,,2'"
        OUT='a:1,a:,a:2,:1,:,:2,b:1,b:,b:2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two args with unique filtering'
        CMD="permutedSet -u 'a b a' '1 2'"
        OUT='a 1 a 2 b 1 b 2'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Argument with newlines'
        CMD="permutedSet -d ',' -s ';' '1${NL}2,3${NL}4'"
        OUT="1${NL}2;3${NL}4"
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Arguments with newlines'
        CMD="permutedSet -d ',' -i ':' -s ';' '1${NL}2,3${NL}4' 'a,b'"
        OUT="1${NL}2:a;1${NL}2:b;3${NL}4:a;3${NL}4:b"
        let STAT=0
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
