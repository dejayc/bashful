#!/bin/bash

# Bashful is copyright 2009-2016 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Requires:
#   bashful.inc.sh
#   bashful-text.inc.sh

# Include basic 'litest' functionality.
source "${0%/*}/../bashful.inc.sh" || exit
source "${BASHFUL_PATH}/bashful-litest.inc.sh" || exit

# Define script dependencies, loaded prior to test execution.
{
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-text.inc.sh" )
}

# Define global variables and constants.
{
    declare -r NL=$'\n'
}

# NOTE: Any occurrence of '&&:' in the source code is designed to preserve
# the $? status of a command while preventing the script from aborting if
# 'set -e' is active.


function testSpec_escEre()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="escapedExtendedRegex 'Hello? I need \$5 (please)'"
        OUT='Hello\? I need \$5 \(please\)'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='No arguments'
        CMD='escapedExtendedRegex'
        OUT=''
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='All special characters'
        CMD="escapedExtendedRegex '\\.?*+{}-^\$|()'"
        OUT='\\\.\?\*\+\{\}\-\^\$\|\(\)'
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

function testSpec_ltrim()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="printf '['; trimmedLeading ''; printf ']'"
        OUT='[]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmedLeading 'none'; printf ']'"
        OUT='[none]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmedLeading '  leading'; printf ']'"
        OUT='[leading]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmedLeading 'trailing  '; printf ']'"
        OUT='[trailing  ]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmedLeading '  both  '; printf ']'"
        OUT='[both  ]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmedLeading '  embedded ws  '; printf ']'"
        OUT='[embedded ws  ]'
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

function testSpec_ordBe()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="orderedBracketExpression ',;[(\-)]'"
        OUT='],;[(\\)-'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="orderedBracketExpression ',;--,--;--'"
        OUT=',;-'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="orderedBracketExpression ',;--,]--;--'"
        OUT='],;-'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='No args'
        CMD="orderedBracketExpression"
        OUT=''
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

function testSpec_rtrim()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="printf '['; trimmedTrailing ''; printf ']'"
        OUT='[]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmedTrailing 'none'; printf ']'"
        OUT='[none]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmedTrailing '  leading'; printf ']'"
        OUT='[  leading]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmedTrailing 'trailing  '; printf ']'"
        OUT='[trailing]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmedTrailing '  both  '; printf ']'"
        OUT='[  both]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmedTrailing '  embedded ws  '; printf ']'"
        OUT='[  embedded ws]'
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

function testSpec_trim()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="printf '['; trimmed ''; printf ']'"
        OUT='[]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmed 'none'; printf ']'"
        OUT='[none]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmed '  leading'; printf ']'"
        OUT='[leading]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmed 'trailing  '; printf ']'"
        OUT='[trailing]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmed '  both  '; printf ']'"
        OUT='[both]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="printf '['; trimmed '  embedded ws  '; printf ']'"
        OUT='[embedded ws]'
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

executeLitest "${@-}"
