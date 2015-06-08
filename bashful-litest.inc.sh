#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Initialize the namespace presence indicator.
{
    declare BASHFUL_MODULE_LITEST='bashful-litest.inc.sh'
}

# Define global variables for test specifications.  This is much easier than
# trying to pass multiline test results back from a testSpec function.
{
    declare TEST_DESC=''
    declare TEST_CMD=''
    declare TEST_EXP_OUTPUT=''
    declare -i TEST_EXP_STATUS=0
}

# function executeLitest:
#
# Refer to function _showUsage for a description of how Litest works.
function executeLitest()
{
    declare -i IGNORE_FAIL=0
    declare -i ITERATIONS=0
    declare -i VERBOSITY=1

    # Parse function options.
    declare -i OPTIND
    local OPT=''

    while getopts ":chist:v" OPT
    do
        case "${OPT}" in
        'c')
            clear
            ;;
        'h')
            _showUsage
            return
            ;;
        'i')
            let IGNORE_FAIL=1
            ;;
        's')
            let VERBOSITY=0
            ;;
        't')
            let ITERATIONS=${OPTARG}
            ;;
        'v')
            let VERBOSITY=2
            ;;
        *)
            echo "ERROR: Unknown flag '${OPTARG}'" >&2
            return 2
        esac
    done
    shift $(( OPTIND - 1 ))
    # Done parsing function options.

    local TEST_NAME="${1}"
    shift

    case "${TEST_NAME}" in
    '')
        _listAllTestNames
        ;;
    'all')
        _executeAllTests \
            "${*}" ${IGNORE_FAIL} ${VERBOSITY} ${ITERATIONS}
        ;;
    'list')
        _listAllTestNames "${*}"
        ;;
    *)
        _executeTestCasesForTest \
            "${TEST_NAME}" "${*}" ${IGNORE_FAIL} ${VERBOSITY} ${ITERATIONS}
        ;;
    esac
}

# Sample testSpec function to demonstrate usage.
function testSpec__litest()
{
    TEST_CASE="${1}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0

    # Automatically-incremented integers are used to designate the test cases,
    # just for simplicity of maintenance.  Textual test names could be used
    # here instead, if desired.
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        DESC="Test basic 'echo' functionality"
        CMD="echo -n 'hello'"
        OUT='hello'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='This test fails to match output'
        CMD="echo -n 'gotcha'"
        OUT='hello'
        let STAT=0
        ;;
    $(( I++ )) )
        DESC='This test fails to match status'
        CMD="echo -n 'hello'"
        OUT='hello'
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

function testSpecs_all()
{
    declare -i SUPPRESS_HIDDEN="${1}"

    local FN_DECL_LIST="$( declare -f -F )"
    local TEST_NAME_LIST=''

    while read -r TEST_SPEC
    do
        local TEST_NAME="${TEST_SPEC#declare -f testSpec_}"

    declare -i OMIT_HIDDEN="${1}"

        [[ "${TEST_NAME}" == "${TEST_SPEC}" ]] && continue
        [[ "${TEST_NAME:0:1}" != '_' ||
           "${SUPPRESS_HIDDEN}" -eq 0 ]] && {

            TEST_NAME_LIST="${TEST_NAME_LIST} ${TEST_NAME}"
        }
    done <<< "${FN_DECL_LIST}"

    echo "${TEST_NAME_LIST# }"
}

function _describeAllTestCases()
{
    local TEST_NAMES_LIST
    TEST_NAMES_LIST=" $( _getAllTestNames 1 ) " || return

    declare -a TEST_NAMES=()
    read -r -a TEST_NAMES <<< "${TEST_NAMES_LIST}"
    declare -i TEST_NAMES_LEN=${#TEST_NAMES[@]}
    declare -i I=0

    while [ ${I} -lt ${TEST_NAMES_LEN} ]
    do
        local TEST_NAME="${TEST_NAMES[I]}"
        let I++

        _describeAllTestCasesForTest "${TEST_NAME}"
        echo
    done
}

function _describeAllTestCasesForTest()
{
    local TEST_NAME="${1}"

    echo "The following test cases are available for test '${TEST_NAME}':"

    TEST_CASES_LIST="$( _getAllTestCasesForTest "${TEST_NAME}" )" || return

    declare -a TEST_CASES
    read -r -a TEST_CASES <<< "${TEST_CASES_LIST}"
    declare -i TEST_CASES_LEN=${#TEST_CASES[@]}
    declare -i I=0

    while [ ${I} -lt ${TEST_CASES_LEN} ]
    do
        local TEST_CASE="${TEST_CASES[I]}"
        let I++

        _executeTestSpecForTestCase "${TEST_NAME}" "${TEST_CASE}" || return

        echo "${TEST_CASE}: ${TEST_DESC}"
    done
}

function _executeAllTests()
{
    local TEST_NAMES_LIST="${1}"
    declare -i IGNORE_FAIL="${2}"
    declare -i VERBOSITY="${3}"
    declare -i ITERATIONS="${4}"

    [[ -n "${TEST_NAMES_LIST}" ]] || {

        TEST_NAMES_LIST=" $( _getAllTestNames 1 ) " || return
    }

    _verifyTestNames "${TEST_NAMES_LIST}" || return

    declare -a TEST_NAMES
    read -r -a TEST_NAMES <<< "${TEST_NAMES_LIST}"
    declare -i TEST_NAMES_LEN=${#TEST_NAMES[@]}
    declare -i I=0

    while [ ${I} -lt ${TEST_NAMES_LEN} ]
    do
        _executeTestCasesForTest \
            "${TEST_NAMES[I]}" all \
            ${IGNORE_FAIL} ${VERBOSITY} ${ITERATIONS} || return

        let I++
    done
}

function _executeTestCase()
{
    local TEST_NAME="${1}"
    local TEST_CASE="${2}"
    local TEST_DESC="${3}"
    local TEST_CMD="${4}"
    local EXPECTED_OUTPUT="${5}"
    declare -i EXPECTED_STATUS="${6}"
    declare -i VERBOSITY="${7}"

    if [ -n "${TEST_DESC}" ]
    then
        [[ -n "${TEST_CMD}" && "${TEST_CMD}" != "${TEST_DESC}" ]] && {

            printf -v TEST_DESC '%b\n  %b' "${TEST_DESC}" "${TEST_CMD}"
        }
    else
        TEST_DESC="${TEST_CMD}"
    fi

    local HEADER="EXECUTING test '${TEST_NAME}' case '${TEST_CASE}'"

    if [ ${VERBOSITY} -eq 2 ]
    then
        echo "${HEADER}"
        echo
        echo "  ${TEST_DESC}"
        echo
    else
        printf '%s: ' "${HEADER}"
    fi

    declare -i STATUS=0
    local OUTPUT
    OUTPUT="$( eval "${TEST_CMD}" )" || let STATUS=${?}

    [[ ${STATUS} -eq ${EXPECTED_STATUS} && \
       "${OUTPUT}" == "${EXPECTED_OUTPUT}" ]] && {

        echo 'PASS'
        [[ ${VERBOSITY} -eq 2 ]] && echo
        return 0
    }

    echo 'FAIL'

    [[ ${VERBOSITY} -ne 0 ]] && {

        echo "${TEST_DESC}"
        echo
    }

    [[ ${VERBOSITY} -gt 0 ]] && {

        if [ ${STATUS} -ne ${EXPECTED_STATUS} ]
        then
            echo \
"Status ${STATUS} did not match expected status ${EXPECTED_STATUS}"
            echo
        else
            cat \
<<ERROR_MSG
The following output:

  ${OUTPUT}

did not match the expected output:

  ${EXPECTED_OUTPUT}

ERROR_MSG
        fi
    }

    return 1
}

function _executeTestCasesForTest()
{
    local TEST_NAME="${1}"
    local TEST_CASES_LIST="${2}"
    declare -i IGNORE_FAIL="${3}"
    declare -i VERBOSITY="${4}"
    declare -i ITERATIONS="${5}"

    case "${TEST_CASES_LIST}" in
    '')
        _listTestCasesForTest "${TEST_NAME}"
        return
        ;;
    'all')
        TEST_CASES_LIST="$( _getAllTestCasesForTest "${TEST_NAME}" )" \
            || return
        ;;
    'list')
        _describeAllTestCasesForTest "${TEST_NAME}"
        return
        ;;
    *)
        _verifyTestCases "${TEST_NAME}" "${TEST_CASES_LIST}" || return
        ;;
    esac

    declare -a TEST_CASES
    read -r -a TEST_CASES <<< "${TEST_CASES_LIST}"
    declare -i TEST_CASES_LEN=${#TEST_CASES[@]}
    declare -i I=0

    while [ ${I} -lt ${TEST_CASES_LEN} ]
    do
        local TEST_CASE="${TEST_CASES[I]}"
        let I++

        _executeTestSpecForTestCase "${TEST_NAME}" "${TEST_CASE}" || return

        if [ ${ITERATIONS} -gt 0 ]
        then
            _executeTestLoop \
                "${TEST_NAME}" "${TEST_CASE}" "${TEST_DESC}" "${TEST_CMD}" \
                ${ITERATIONS} ${VERBOSITY} ${IGNORE_FAIL}
        else
            declare -i STATUS=0

            _executeTestCase \
                "${TEST_NAME}" "${TEST_CASE}" "${TEST_DESC}" "${TEST_CMD}" \
                "${TEST_EXP_OUTPUT}" ${TEST_EXP_STATUS} ${VERBOSITY}

            let STATUS=${?}

            [[ ${STATUS} -eq 0 || ${IGNORE_FAIL} -ne 0 ]] || return ${STATUS}
        fi
    done
}

function _executeTestLoop()
{
    local TEST_NAME="${1}"
    local TEST_CASE="${2}"
    local TEST_DESC="${3}"
    local TEST_CMD="${4}"
    declare -i ITERATIONS="${5}"
    declare -i VERBOSITY="${6}"
    declare -i IGNORE_FAIL="${7}"

    declare -i STATUS=0
    declare -i I=0

    if [ ${IGNORE_FAIL} -ne 0 ]
    then
        IFS='' read -r -d '' EVAL \
<<EVAL
        while [ \${I} -lt \${ITERATIONS} ]
        do
            ${TEST_CMD} >/dev/null
            STATUS=\${?}
            let I++
        done
EVAL
    else
        IFS='' read -r -d '' EVAL \
<<EVAL
        while [ \${I} -lt \${ITERATIONS} ]
        do
            ${TEST_CMD} >/dev/null || {

                STATUS=\${?}
                break
            }
            let I++
        done
EVAL
    fi

    echo "EXECUTING test '${TEST_NAME}' case '${TEST_CASE}' @ ${ITERATIONS}x"
    echo

    [[ -n "${TEST_DESC}" ]] && echo "  ${TEST_DESC}"

    echo "  ${TEST_CMD}"

    time (
        eval "${EVAL}"
        echo
        echo "${I} out of ${ITERATIONS} completed; final status was ${STATUS}"
    )
    echo
}

function _executeTestSpecForTestCase()
{
    local TEST_NAME="${1}"
    local TEST_CASE="${2}"

    local SPEC_FN
    SPEC_FN="$( _getTestSpecFn "${TEST_NAME}" )" || return

    eval "${SPEC_FN}" "${TEST_CASE}" || {

        declare -i STATUS=${?}

        echo \
"ERROR: '${SPEC_FN} ${TEST_CASE}' returned an error status code" >&2

        return ${STATUS}
    }
}

function _getAllTestCasesForTest()
{
    local TEST_NAME="${1}"

    local SPEC_FN
    SPEC_FN="$( _getTestSpecFn "${TEST_NAME}" )" || return

    local TEST_CASES_LIST
    TEST_CASES_LIST="$( eval "${SPEC_FN}" all )" || {

        declare -i STATUS=${?}
        echo "ERROR: '${SPEC_FN} all' returned an error status code" >&2
        return ${STATUS}
    }

    echo -n "${TEST_CASES_LIST}"
}

function _getAllTestNames()
{
    declare -i SUPPRESS_HIDDEN="${1}"

    local TEST_NAMES_LIST
    TEST_NAMES_LIST="$( testSpecs_all ${SUPPRESS_HIDDEN} )" || {

        declare -i STATUS=${?}
        echo "ERROR: '${SPEC_FN}' returned an error status code" >&2
        return ${STATUS}
    }

    echo -n "${TEST_NAMES_LIST}"
}

function _getTestSpecFn()
{
    local TEST_NAME="${1}"

    [[ -n "${TEST_NAME}" ]] || {

        echo "INTERNAL ERROR: Missing test name" >&2
        return 1
    }

    local SPEC_FN="testSpec_${TEST_NAME}"

    declare -f -F "${SPEC_FN}" &> /dev/null || {

        SPEC_FN="testSpec__${TEST_NAME}"

        declare -f -F "${SPEC_FN}" &> /dev/null || {

            echo "ERROR: Unknown test '${TEST_NAME}'" >&2
            return 1
        }
    }

    echo -n "${SPEC_FN}"
}

function _iterateTo()
{
    declare -i I="${1}"
    declare -i L=$(( I - 1 ))
    declare -i J=1
    while [ ${J} -lt ${L} ]
    do
        echo -n "${J} "
        let J++
    done

    [[ ${J} -eq ${L} ]] && echo "${J}"
    return
}

function _listAllTestNames()
{
    local TEST_NAMES_LIST="${1}"

    declare -a TEST_NAMES
    read -r -a TEST_NAMES <<< "${TEST_NAMES_LIST}"
    declare -i TEST_NAMES_LEN=${#TEST_NAMES[@]}

    if [ ${TEST_NAMES_LEN} -gt 0 ]
    then
        [[ ${TEST_NAMES_LEN} -ne 0 && "${TEST_NAMES[0]}" == 'all' ]] && {

            _describeAllTestCases
            return
        }

        declare -i I=0

        while [ ${I} -lt ${TEST_NAMES_LEN} ]
        do
            _describeAllTestCasesForTest "${TEST_NAMES[I]}"
            let I++

            [[ ${I} -lt TEST_NAMES_LEN ]] && echo
        done
    else
        local TEST_NAMES_LIST
        TEST_NAMES_LIST="$( _getAllTestNames 1 )" || return

        echo 'The following tests are available:'
        echo "${TEST_NAMES_LIST}"
    fi
}

function _listTestCasesForTest()
{
    local TEST_NAME="${1}"

    local TEST_CASES_LIST
    TEST_CASES_LIST="$( _getAllTestCasesForTest "${TEST_NAME}" )" || return

    echo "The following test cases are available for test '${TEST_NAME}':"
    echo "${TEST_CASES_LIST}"
    echo
    echo "Specify '${TEST_NAME} list' to list all test case descriptions."
}

function _showUsage()
{
    local CMD="${0##*/}"
    local USAGE_TEXT
    local USAGE_SYNOPSIS

    IFS='' read -r -d '' USAGE_SYNOPSIS <<USAGE_SYNOPSIS
Usage: ${CMD}
       ${CMD} -h
       ${CMD} [-c] [-i] [-s] [-t count] 'all' [group ...]
       ${CMD} [-c] [-i] [-s] [-t count] [group 'all']
       ${CMD} [-c] [-i] [-s] [-t count] [group [case ...]]
       ${CMD} 'list' ['all']
       ${CMD} 'list' [group ...]
       ${CMD} [group] 'list'
USAGE_SYNOPSIS

    IFS='' read -r -d '' USAGE_TEXT <<'USAGE_TEXT'
  Executes the specified test cases within the specified test group,
  optionally timing the duration required to execute the specified number of
  test iterations.

  If no test groups are specified, or 'list' is specified without test cases,
  the list of available test groups will be listed.

  If 'list' 'all' is specified, all test cases for all test groups will be
  listed with descriptions.

  If 'list' is specified with one or more test groups, all test cases for the
  specified test groups will be listed with descriptions.

  If a test group is specified without test cases, the list of available test
  cases for the specified test group will be listed.

  If 'all' is specified without test cases, all test cases within all test
  groups will be executed.

  If 'all' is specified with one or more test groups, all test cases within
  the specified test groups will be executed.

  If a test group is specified with one or more test cases, the specified test
  cases will be executed.

  If a test group is specified with 'all' as the next argument, all test cases
  for the specified test group will be executed.

  If a test group is specified with 'list' as the next argument, all test cases
  for the specified test group will be listed with descriptions.

  Litest may be called with the following optional flags:

  -c causes the screen to be cleared prior to test execution.

  -h shows usage information.

  -i allows remaining test cases to be executed even if some test cases fail.
     By default, Litest aborts the execution of remaining test cases if one
     fails.

  -s reports the results of each test case in a summarized format, supressing
     the test description, executed test command, and superfluous whitespace.
     By default, only passing tests are summarized, and failing tests are
     reported in verbose mode.

  -t allows an iteration count to be specified, which causes test executions
     to be timed as they are executed the specified number of iterations.

  -v reports the results of each test case in verbose format, in which the
     description and executed command for each test case is reported.  By
     default, only failing tests are reported in verbose mode.

  Each test group must correlate with a function created by the test author.
  The name of the function must consist of the format 'testSpec_GROUP', where
  GROUP must be replaced with the actual name of the test group.  For example,
  if the test author created a test group named 'text', a function must exist
  named 'testSpec_text'.

  'testSpec' functions may be designated as 'hidden' by naming the prefix of
  the function as 'testSpec__' (with two underscores) instead of 'testSpec_'.
  Doing so will cause the test to be omitted from all lists of tests available
  to be run, and will also cause the test to be skipped when 'all' tests are
  run.

  The purpose of the 'testSpec' functions are to accept a single parameter as
  input, which designates the test case to execute, and in response, set the
  following global variables to define the behavior of the test case:

     TEST_DESC: A brief, human-readable description of the test case goals.
        E.g. "Test basic 'echo' functionality"

     TEST_CMD: The shell command that comprises the test case to execute.
        E.g. "echo 'hello'"

     TEST_EXP_OUTPUT: The output expected to be received as a result of
        executing TEST_CMD.  The test will be considered a failure if the
        actual command output doesn't match the expected output.  E.g. 'hello'

     TEST_EXP_STATUS: The status value expected to be returned upon execution
        of TEST_CMD.  The test will be considered a failure if the actual
        command status doesn't match the expected status.  E.g. 0

  The testSpec function must also be capable of echoing the entire list of
  supported test cases for the test group, if 'all' is received as the first
  parameter.  For example, 'testSpec_text all' might echo 'echo sort unique'
  in response.

  'testSpec' functions that return a status code other than 0 will cause
  Litest to abort.

  For simplicity, the test author may choose to use ascending integers instead
  of textual test case names.  For reference on how to easily implement this,
  refer to the reference function 'testSpec__litest'.
USAGE_TEXT

    echo "${USAGE_SYNOPSIS}"
    echo "${USAGE_TEXT}"
}

function _verifyTestCases()
{
    local TEST_NAME="${1}"
    local TEST_CASES_LIST="${2}"

    local ALL_TEST_NAMES
    ALL_TEST_NAMES=" $( _getAllTestCasesForTest "${TEST_NAME}" ) " || return

    declare -a TEST_CASES=()
    read -r -a TEST_CASES <<< "${TEST_CASES_LIST}"
    declare -i TEST_CASES_LEN=${#TEST_CASES[@]}
    declare -i I=0

    while [ ${I} -lt ${TEST_CASES_LEN} ]
    do
        local TEST_CASE="${TEST_CASES[I]}"
        let I++

        [[ "${ALL_TEST_NAMES}" =~ " ${TEST_CASE} " ]] || {

            echo \
"ERROR: Unknown test case '${TEST_CASE}' for test '${TEST_NAME}'" >&2

            return 1
        }
    done
}

function _verifyTestNames()
{
    local TEST_NAMES_LIST="${1}"

    local ALL_TEST_NAMES
    ALL_TEST_NAMES=" $( _getAllTestNames ) " || return

    declare -a TEST_NAMES=()
    read -r -a TEST_NAMES <<< "${TEST_NAMES_LIST}"
    declare -i TEST_NAMES_LEN=${#TEST_NAMES[@]}
    declare -i I=0

    while [ ${I} -lt ${TEST_NAMES_LEN} ]
    do
        local TEST_NAME="${TEST_NAMES[I]}"
        let I++

        [[ "${ALL_TEST_NAMES}" =~ " ${TEST_NAME} " ]] || {

            echo "ERROR: Unknown test '${TEST_NAME}'" >&2
            return 1
        }
    done
}
