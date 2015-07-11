#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Requires:
#   bashful.inc.sh
#   bashful-litest.inc.sh
#   bashful-list.inc.sh

# Include basic 'litest' functionality.
source "${0%/*}/../bashful.inc.sh" || exit
source "${BASHFUL_PATH}/bashful-litest.inc.sh" || exit

# Define script dependencies, loaded prior to test execution.
{
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-list.inc.sh" )
}

# Define global variables and constants.
{
    declare -r NL=$'\n'
}

# NOTE: Any occurrence of '&&:' in the source code is designed to preserve
# the $? status of a command while preventing the script from aborting if
# 'set -e' is active.


function testSpec_joinlist()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="joinedList -s ',' a b c d e"
        OUT='a,b,c,d,e'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="joinedList -s ';' -S a b c d e"
        OUT='a;b;c;d;e;'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="joinedList -s ',' a ''"
        OUT='a,,'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="joinedList -s ',' -S a ''"
        OUT='a,,'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="joinedList -s ',' '' ''"
        OUT=',,'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="joinedList -q '' ''"
        OUT="'' '' "
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="joinedList -q 'hello there' 'my \"friend\"'"
        OUT='hello\ there my\ \"friend\"'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="joinedList -q -s ';' 'hello there' 'my \"friend\"'"
        OUT='hello\ there;my\ \"friend\"'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
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

function testSpec_splitlist()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    # Newline delimiter; Trailing delimiter
    # IFS="\n" "hello\n"
    # here-string: "hello\n\n"
    # read -a: ( "hello" )
    # Action: Do nothing

    # Newline delimiter; Trailing non-delimiter
    # IFS="\n" "hello"
    # here-string: "hello\n"
    # read -a: ( "hello" )
    # Action: Do nothing

    # Non-newline delimiter; Trailing newline
    # IFS=',' "hello\n"
    # here-string: "hello\n\n"
    # read -a: ( "hello\n\n" )
    # Action: Strip trailing newline from last output item

    # Non-newline delimiter; Trailing non-newline non-delimiter
    # IFS=',' "hello"
    # here-string: "hello\n"
    # read -a: ( "hello\n" )
    # Action: Strip trailing newline from last output item

    # Non-newline delimiter; Trailing delimiter
    # IFS=',' "hello,"
    # here-string "hello,\n"
    # read -a: ( "hello" "\n" )
    # Action: Strip trailing delimiter from input
    # Action: Strip trailing newline from last output item

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="splitList -d ',' 'a,b' ',c'"
        OUT="a b '' c"
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="splitList -d ',' 'a,'"
        OUT="a"
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="splitList -d ',' 'a,,'"
        OUT="a ''"
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="splitList -d ',' ',,'"
        OUT="'' ''"
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="splitList -d ',' 'a,b,' ',c'"
        OUT="a b '' c"
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="splitList -d ',' 'a,b,,' ',c'"
        OUT="a b '' '' c"
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="splitList -d ',' 'hello,there' 'my \"friend\"'"
        OUT='hello there my\ \"friend\"'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="splitList -d '' 'hi there' 'bye'"
        OUT='h i \  t h e r e b y e'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
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

function testSpec_translist()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="translatedList a b a c b d a"
        OUT='a b a c b d a'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="translatedList -r a b a c b d a"
        OUT='a d b c a b a'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="translatedList -u a b a c b d a"
        OUT='a b c d'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="translatedList -r -u a b a c b d a"
        OUT='a d b c'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="translatedList -s ';' -S a b a c b d a"
        OUT='a;b;a;c;b;d;a;'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="translatedList -t ' leading' ' both ' 'trailing '"
        OUT='leading both trailing'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="translatedList -s ',' 1 2 '' 4 '' 5"
        OUT='1,2,4,5'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="translatedList -s ',' -n 1 2 '' 4 '' 5"
        OUT='1,2,,4,,5'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="translatedList -s ',' -n -u 1 2 '' 4 '' 5"
        OUT='1,2,,4,5'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="translatedList -q 'hello there' 'my \"friend\"' '\`whoami\`'"
        OUT="hello\\ there my\\ \\\"friend\\\" \\\`whoami\\\`"
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="translatedList -s ',' -q 'hello there' 'my \"friend\"'"
        OUT="hello\\ there,my\\ \\\"friend\\\""
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Unique with duplicate at end'
        CMD="translatedList -u a b c a"
        OUT='a b c'
        let STAT=0 &&:
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

executeLitest "${@-}"
