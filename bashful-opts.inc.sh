#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Declare the module name and dependencies.
declare BASHFUL_MODULE='opts'
declare BASHFUL_MODULE_DEPENDENCIES='bashful'

# Verify execution context and module dependencies, and register the module.
{
    declare BASHFUL_MODULE_VAR="BASHFUL_LOADED_${BASHFUL_MODULE}"
    [[ -z "${!BASHFUL_MODULE_VAR-}" ]] || return 0

    # Ensure the module is sourced, not executed, generating an error
    # otherwise.
    [[ "${BASH_ARGV}" != '' ]] || {
        echo "ERROR: ${BASH_SOURCE[0]##*/} must be sourced, not executed"
        exit 1
    } >&2

    # Register the module and dependencies.
    declare "${BASHFUL_MODULE_VAR}"="${BASHFUL_MODULE}"
    declare "BASHFUL_DEPS_${BASHFUL_MODULE}"="${BASHFUL_MODULE_DEPENDENCIES}"
}

# Initialize global variables.
{
    # Set by 'processScriptOptions' to indicate how many leading command line
    # parameters comprised options or option values.
    declare -i SCRIPT_OPT_OFFSET=0
}

# NOTE: Any occurrence of '&&:' and '||:' that appears following a command is
# designed to prevent that command from terminating the script when a non-zero
# status is returned while 'set -e' is active.  This is especially necessary
# with the 'let' command, which if used to assign '0' to a variable, is
# treated as a failure.  '&&:' preserves the $? status of a command.  '||:'
# discards the status, which is useful when the last command of a function
# returns a non-zero status, but should not cause the function to be
# considered as a failure.


# Processes command-line options passed to the script.  The first parameter is
# the number of supported command-line parameters, followed by the same number
# of command-line parameter specifications, followed by the actual command-line
# parameters passed to the script.  For each command-line option, a function
# named 'processScriptOption' will be called with the command-line option and
# optional value.  Global variable SCRIPT_OPT_OFFSET will be set to the number
# of command-line parameters that comprised options or option values.
function processScriptOptions()
{
    isFunction processScriptOption || return

    let SCRIPT_OPT_OFFSET=0

    declare -a OPT_SPEC_NAMES=()
    declare -a OPT_SPEC_TYPES=()

    declare -i N=${1-}
    shift ||:

    declare -i L=0
    declare -i OPT_SPEC_COUNT=0

    while [ ${L} -lt ${N} ]
    do
        let L+=1

        local OPT_SPEC_NAME="${1}"
        shift ||:

        declare -i OPT_SPEC_REQUIRES_VALUE=0
        local OPT_SPEC_INDEX=''

        case "${OPT_SPEC_NAME}" in
        *=)
            let OPT_SPEC_REQUIRES_VALUE=1
            OPT_SPEC_NAME="${OPT_SPEC_NAME%=}"
            ;;
        esac

        declare -i OPT_SPEC_COUNT=${#OPT_SPEC_NAMES[@]}

        [[ ${OPT_SPEC_COUNT} -gt 0 ]] && \
            OPT_SPEC_INDEX="$( \
                indexOf "${OPT_SPEC_NAME}" "${OPT_SPEC_NAMES[@]}" )"

        [[ "${OPT_SPEC_INDEX}" != '' ]] || {

            OPT_SPEC_INDEX=${OPT_SPEC_COUNT}
            OPT_SPEC_NAMES[OPT_SPEC_INDEX]="${OPT_SPEC_NAME}"
        }

        OPT_SPEC_TYPES[OPT_SPEC_INDEX]=${OPT_SPEC_REQUIRES_VALUE}
    done

    local OPT_SPEC_SHORT=''
    declare -i OPT_SPEC_HAS_LONG=0

    let L=0
    let N=${#OPT_SPEC_NAMES[@]}

    while [ ${L} -lt ${N} ]
    do
        local OPT_SPEC_NAME="${OPT_SPEC_NAMES[L]}"
        declare -i OPT_SPEC_TYPE=${OPT_SPEC_TYPES[L]}
        let L+=1

        if [ "${#OPT_SPEC_NAME}" -eq 1 ]
        then
            if [ ${OPT_SPEC_TYPE} -eq 0 ]
            then
                OPT_SPEC_SHORT="${OPT_SPEC_SHORT}${OPT_SPEC_NAME}"
            else
                OPT_SPEC_SHORT="${OPT_SPEC_SHORT}${OPT_SPEC_NAME}:"
            fi
        else
            OPT_SPEC_HAS_LONG=1
        fi
    done

    if [ ${OPT_SPEC_HAS_LONG} -ne 0 ]
    then
        OPT_SPEC_SHORT=":${OPT_SPEC_SHORT}-:"
    else
        OPT_SPEC_SHORT=":${OPT_SPEC_SHORT}"
    fi

    # OPT_COUNT counts the number of options processed thus far, and is used
    # as an index into arrays of option attributes.
    declare -i OPT_COUNT=0

    # This variable is used to determine whether the previous short option had
    # its value concatenated to the option, or was separated by whitespace,
    # which determines whether to remove optional equal sign characters
    # prepended to short option values.
    declare -i EXPECTED_OPTIND=2

    local OPT_NAME=''

    while getopts "${OPT_SPEC_SHORT}" OPT_NAME
    do
        let OPT_COUNT+=1

        local OPT_TYPE=''
        local OPT_VALUE=''
        declare -i OPT_CHECK_VALUE=0

        # Set OPTARG in case script is running with 'set -u'.
        OPTARG="${OPTARG-}"

        case "${OPT_NAME}" in
        -)  # A long option was specified.
            case "${OPTARG}" in
            *=*)
                # A long option was specified containing an equal sign, which
                # should be parsed as a name-value pair.
                OPT_VALUE=${OPTARG#*=}
                OPT_NAME=${OPTARG%=$OPT_VALUE}
                ;;

            *)  # A long option was specified without an equal sign, thus the
                # next parameter should be interpreted as its value.
                OPT_NAME="${OPTARG}"

                # The long option might not have a value if the option was the
                # final command-line argument.  This will be checked later.
                OPT_CHECK_VALUE=1
                ;;
            esac
            ;;

        :)  # A short option that requires a value was specified without a
            # value.  Thus, this option was the final parameter to be parsed.
            OPT_NAME="${OPTARG}"
            ;;

        \?) # A short option was specified that was not defined in the spec
            # provided to the getopts call.
            OPT_NAME="${OPTARG}"
            ;;

        *)  # A short option was specified that was defined in the spec
            # provided to the getopts call.

            case "${OPTARG}" in
            =*) # The value begins with an equal sign, which should be removed
                # only if the value was appended to the short option itself,
                # and not separated by whitespace.
                if [ ${OPTIND} -eq ${EXPECTED_OPTIND} ]
                then
                    OPT_VALUE=${OPTARG#=}
                else
                    OPT_VALUE="${OPTARG}"
                fi
                ;;

            *)  # The whole value of the option should be interpreted as-is.
                OPT_VALUE="${OPTARG}"
                ;;
            esac

            ;;
        esac

        let EXPECTED_OPTIND=OPTIND+1

        OPT_SPEC_INDEX="$( indexOf "${OPT_NAME}" "${OPT_SPEC_NAMES[@]}" )"

        if [ "${OPT_SPEC_INDEX}" == '' ]
        then
            ERROR_invalidOption "${OPT_NAME}"
            return
        fi

        [[ ${OPT_CHECK_VALUE} -eq 0 ]] || {

            [[ ${OPT_SPEC_TYPES[OPT_SPEC_INDEX]} -eq 0 ]] || {

                # If OPTIND is less than or equal to the number of command-
                # line parameters, the next command-line parameter can be
                # considered to be the value of the current option.
                if [ ${OPTIND} -le ${#@} ]
                then
                    OPT_VALUE="${!OPTIND}"
                    let OPTIND+=1
                else
                    ERROR_missingOptionValue "${OPT_NAME}"
                    return
                fi
            }
        }

        processScriptOption ${OPT_COUNT} "${OPT_NAME}" "${OPT_VALUE}" || \
            return
    done

    let SCRIPT_OPT_OFFSET=$(( OPTIND - 1 )) ||:
}

function ERROR_invalidOption()
{
    declare -i STATUS=${?}
    declare -i ERR_CODE=20

    local OPTION_NAME="${1?'INTERNAL ERROR: Option not specified'}"

    if [ -n "${2-}" ]
    then
        let ERR_CODE="${2}"
    else
        [[ ${STATUS} -ne 0 ]] && let ERR_CODE=STATUS
    fi

    if [ ${#OPTION_NAME} -eq 1 ]
    then
        OPTION_NAME="-${OPTION_NAME}"
    else
        OPTION_NAME="--${OPTION_NAME}"
    fi

    stderr ${ERR_CODE} <<:ERROR
ERROR: An unsupported option was specified
OPTION: ${OPTION_NAME}$(
    isFunction showHelpHint && ( echo; echo; showHelpHint ) )
:ERROR
}

function ERROR_invalidOptionValue()
{
    declare -i STATUS=${?}
    declare -i ERR_CODE=40

    local OPTION_NAME="${1?'INTERNAL ERROR: Option not specified'}"
    local OPTION_VALUE="${2-}"

    if [ -n "${3-}" ]
    then
        let ERR_CODE="${3}"
    else
        [[ ${STATUS} -ne 0 ]] && let ERR_CODE=STATUS
    fi

    if [ ${#OPTION_NAME} -eq 1 ]
    then
        OPTION_NAME="-${OPTION_NAME}"
    else
        OPTION_NAME="--${OPTION_NAME}"
    fi

    stderr ${ERR_CODE} <<:ERROR
ERROR: An invalid value was specified for an option
OPTION: ${OPTION_NAME}
VALUE: ${OPTION_VALUE}$(
    isFunction showHelpHint && ( echo; echo; showHelpHint ) )
:ERROR
}

function ERROR_missingOption()
{
    declare -i STATUS=${?}
    declare -i ERR_CODE=20

    local OPTION_NAME="${1?'INTERNAL ERROR: Option not specified'}"

    if [ -n "${2-}" ]
    then
        let ERR_CODE="${2}"
    else
        [[ ${STATUS} -ne 0 ]] && let ERR_CODE=STATUS
    fi

    if [ ${#OPTION_NAME} -eq 1 ]
    then
        OPTION_NAME="-${OPTION_NAME}"
    else
        OPTION_NAME="--${OPTION_NAME}"
    fi

    stderr ${ERR_CODE} <<:ERROR
ERROR: A required option was missing
OPTION: ${OPTION_NAME}$(
    isFunction showHelpHint && ( echo; echo; showHelpHint ) )
:ERROR
}

function ERROR_missingOptionValue()
{
    declare -i STATUS=${?}
    declare -i ERR_CODE=20

    local OPTION_NAME="${1?'INTERNAL ERROR: Option not specified'}"

    if [ -n "${2-}" ]
    then
        let ERR_CODE="${2}"
    else
        [[ ${STATUS} -ne 0 ]] && let ERR_CODE=STATUS
    fi

    if [ ${#OPTION_NAME} -eq 1 ]
    then
        OPTION_NAME="-${OPTION_NAME}"
    else
        OPTION_NAME="--${OPTION_NAME}"
    fi

    stderr ${ERR_CODE} <<:ERROR
ERROR: An option that requires a value was missing the value
OPTION: ${OPTION_NAME}$(
    isFunction showHelpHint && ( echo; echo; showHelpHint ) )
:ERROR
}
