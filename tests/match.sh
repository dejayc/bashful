#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Requires:
#   bashful.inc.sh
#   bashful-list.inc.sh
#   bashful-litest.inc.sh
#   bashful-match.inc.sh

# Include basic 'litest' functionality.
source "${0%/*}/../bashful.inc.sh" || exit
source "${BASHFUL_PATH}/bashful-litest.inc.sh" || exit

# Define script dependencies, loaded prior to test execution.
{
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-list.inc.sh" )
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-match.inc.sh" )
}

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
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='No arguments'
        CMD='escapedExtendedRegex'
        OUT=''
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='All special characters'
        CMD="escapedExtendedRegex '\\.?*+{}-^\$|()'"
        OUT='\\\.\?\*\+\{\}\-\^\$\|\(\)'
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

function testSpec_ifWc()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="ifWildcardMatches 'tortoise' 'tortoise'"
        OUT=''
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="ifWildcardMatches 'tortoise' 'porpoise'"
        OUT=''
        DESC="Example: ${CMD}"
        let STAT=1
        ;;
    $(( I++ )) )
        CMD="ifWildcardMatches 'tortoise' '?or?oise'"
        OUT=''
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="ifWildcardMatches 'tortoise' '*oise'"
        OUT=''
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="ifWildcardMatches 'tortoise' 'tort'"
        OUT=''
        DESC="Example: ${CMD}"
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='No args'
        CMD="ifWildcardMatches"
        OUT=''
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Empty arg'
        CMD="ifWildcardMatches ''"
        OUT=''
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='Two empty args'
        CMD="ifWildcardMatches '' ''"
        OUT=''
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
        CMD="orderedBracketExpression ',;[(-)]'"
        OUT='],;[()-'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="orderedBracketExpression ',;--,--;--'"
        OUT=',;-'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="orderedBracketExpression ',;--,]--;--'"
        OUT='],;-'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='No args'
        CMD="orderedBracketExpression"
        OUT=''
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

function testSpec_valname()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="valueForMatchedName '3' '1=a' '2=b' '3=c'"
        OUT='c'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="valueForMatchedName -w 'book' 'b*=1' 'bo*=2' 'b?o*=3'"
        OUT='1'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="valueForMatchedName -w -l 'book' 'b*=1' 'bo*=2' 'b?o*=3'"
        OUT='3'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="valueForMatchedName '' 'empty' '=value'"
        OUT='value'
        DESC="Example: ${CMD}"
        let STAT=0
        ;;
    $(( I++ )) )
        CMD="valueForMatchedName -v '' 'empty' '=value'"
        OUT='empty'
        DESC="Example: ${CMD}"
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

executeLitest "${@-}"
