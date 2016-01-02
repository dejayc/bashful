#!/bin/bash

# Bashful is copyright 2009-2016 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Requires:
#   bashful.inc.sh
#   bashful-list.inc.sh
#   bashful-litest.inc.sh
#   bashful-match.inc.sh
#   bashful-seq.inc.sh
#   bashful-ssh-spec.inc.sh

# Include basic 'litest' functionality.
source "${0%/*}/../bashful.inc.sh" || exit
source "${BASHFUL_PATH}/bashful-litest.inc.sh" || exit

# Define script dependencies, loaded prior to test execution.
{
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-list.inc.sh" )
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-text.inc.sh" )
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-match.inc.sh" )
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-seq.inc.sh" )
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-ssh-spec.inc.sh" )
}

# Define global variables and constants.
{
    declare -r BS='\'
}

# NOTE: Any occurrence of '&&:' in the source code is designed to preserve
# the $? status of a command while preventing the script from aborting if
# 'set -e' is active.


function testSpec_parspec()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="parsedSshSpecs '10.1.1.1: /ftp;'"
        OUT="10.1.1.1 /ftp '' '' '' "
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="parsedSshSpecs ' 10.1.1.1 : /ftp ;'"
        OUT="10.1.1.1 /ftp '' '' '' "
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD=\
"parsedSshSpecs 'user@10.[1,2].1.1: /ftp;' 'user@10.*: /home/cert;'"
        OUT=\
"user@10.1.1.1 /ftp /home/cert '' '' user@10.2.1.1 /ftp /home/cert '' '' "
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD=\
"parsedSshSpecs 'user@10.[1,2].1.1: /ftp;' "\
"'user@10.1.*: /home/cert1; user@10.2.*: /home/cert2;'"
        OUT=\
"user@10.1.1.1 /ftp /home/cert1 '' '' user@10.2.1.1 /ftp /home/cert2 '' '' "
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD=\
"parsedSshSpecs 'user@10.[1,2].1.1: /ftp;' "\
"'10.3.*: /home/jump; *: /home/cert;' '10.2.*: 10.3.1.1;'"
        OUT=\
"user@10.1.1.1 /ftp /home/cert '' '' "\
"user@10.2.1.1 /ftp /home/cert 10.3.1.1 /home/jump "
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

function testSpec_permap()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="permutedSshMap '[www,app][1-3]: /ftp;'"
        OUT='www1:/ftp www2:/ftp www3:/ftp app1:/ftp app2:/ftp app3:/ftp'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSshMap ' [www,app][1-3] : /ftp ;'"
        OUT='www1:/ftp www2:/ftp www3:/ftp app1:/ftp app2:/ftp app3:/ftp'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSshMap "\
"'host1: uname -a${BS}; ls -al${BS};;host2: pwd${BS};;'"
        OUT='host1:uname\ -a\;\ ls\ -al\; host2:pwd\;'
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

function testSpec_valhost()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="valueForMatchedSshHost 'user@10.1.1.1' '10.1.*:ten-one'"
        OUT='ten-one'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD=\
"valueForMatchedSshHost 'user@10.2.1.1' '10.1.*:ten-one' 'user@10.*:user-ten'"
        OUT='user-ten'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD=\
"valueForMatchedSshHost 'user@10.2.1.1' "\
"' 10.1.* : ten-one ' ' user@10.* : user-ten '"
        OUT='user-ten'
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

function testSpec_valhosts()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="valuesForMatchedSshHosts '10.1.*:ten-one' 'user@10.1.1.1'"
        OUT='ten-one '
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD=\
"valuesForMatchedSshHosts "\
"'10.1.*:ten-one; user@10.*:user-ten' 'user@10.2.1.1' '10.1.1.1'"
        OUT='user-ten ten-one '
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD=\
"valuesForMatchedSshHosts "\
"' 10.1.* : ten-one ; user@10.* : user-ten ' 'user@10.2.1.1' '10.1.1.1'"
        OUT='user-ten ten-one '
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
