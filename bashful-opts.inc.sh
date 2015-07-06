#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Initialize the namespace presence indicator, and verify dependencies.
{
    declare BASHFUL_MODULE_OPTS='bashful-opts.inc.sh'

    [[ -n "${BASHFUL_VERSION-}" ]] || {

        echo "Aborting loading of '${BASHFUL_MODULE_OPTS}':"
        echo "Dependency 'bashful.inc.sh' is not loaded"
        exit 2
    } >&2
}

# Initialize global variables.
{
    # Variables for processing command-line options.
    declare -a SCRIPT_OPT_NAMES=()
    declare -a SCRIPT_OPT_VALUES=()
    declare -a SCRIPT_OPT_VALID_STATUS=()
    declare -i SCRIPT_OPT_OFFSET=0
    declare -a SCRIPT_OPT_SPEC=()
    declare -a SCRIPT_OPT_SPEC_PARAM_NAMES=()
    declare -a SCRIPT_OPT_SPEC_PARAM_TYPES=()
    declare    SCRIPT_OPT_SPEC_SHORT=''
}

# NOTE: Any occurrence of '&&:' in the source code is designed to preserve
# the $? status of a command while preventing the script from aborting if
# 'set -e' is active.


# Parse the command-line options passed to the script, based on the
# configuration previously passed to 'script_prepareOptions'.
function script_parseOptions()
{
    SCRIPT_OPT_NAMES=()
    SCRIPT_OPT_VALUES=()
    SCRIPT_OPT_VALID_STATUS=()
    SCRIPT_OPT_OFFSET=0

    [[ ${#SCRIPT_OPT_SPEC_PARAM_NAMES[@]-} -gt 0 ]] || return

    # OPT_COUNT counts the number of options processed thus far, and is used
    # as an index into arrays of option attributes.
    declare -i OPT_COUNT=0

    # LAST_INDEX is used to determine whether the previous short option had
    # its value concatenated to the option, or was separated by whitespace,
    # which determines whether to remove optional equal sign characters
    # prepended to short option values.
    declare -i LAST_INDEX=1

    while getopts "${SCRIPT_OPT_SPEC_SHORT}" OPT_NAME
    do
        let OPT_COUNT+=1
        let LAST_INDEX+=1
        let SCRIPT_OPT_OFFSET+=1

        local OPT_TYPE=''
        local OPT_VALUE=''
        local OPT_SPEC_INDEX=''
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

                # Our long option might 
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
            =*) # The value beings with an equal sign, which should be removed
                # if the value was concatenated to the short option itself,
                # thus not separated by whitespace.
                if [ ${OPTIND} -eq ${LAST_INDEX} ]
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

        # Update LAST_INDEX to be the same value as the last OPTIND.
        let LAST_INDEX=OPTIND &&:

        OPT_SPEC_INDEX="$( indexOf "${OPT_NAME}" \
            "${SCRIPT_OPT_SPEC_PARAM_NAMES[@]}" )"

        if [ "${OPT_SPEC_INDEX}" == '' ]
        then
            SCRIPT_OPT_VALID_STATUS[OPT_COUNT-1]=1
        else
            SCRIPT_OPT_VALID_STATUS[OPT_COUNT-1]=0

            [[ ${OPT_CHECK_VALUE} -ne 0 ]] && {

                OPT_TYPE="${SCRIPT_OPT_SPEC_PARAM_TYPES[OPT_SPEC_INDEX]}"

                [[ "${OPT_TYPE}" == 'with-value' ]] && {

                    # Only advance the offset if OPTIND is not greater than the
                    # number of command-line parameters, which indicates that
                    # the current command-line argument is not the final one,
                    # and thus the next argument should be considered a value.
                    [[ ${OPTIND} -le ${#@} ]] && {

                        OPT_VALUE="${!OPTIND}"
                        OPTIND=$(( OPTIND + 1 ))
                        let SCRIPT_OPT_OFFSET+=1
                    }
                }
            }
        fi

        SCRIPT_OPT_NAMES[OPT_COUNT-1]="${OPT_NAME}"
        SCRIPT_OPT_VALUES[OPT_COUNT-1]="${OPT_VALUE}"
    done
}

# Receive a configuration that specifies the command-line options supported by
# the script, and update global variables accordingly so that command-line
# options may be parsed when 'script_parseOptions' is invoked.
function script_prepareOptions()
{
    SCRIPT_OPT_SPEC_PARAM_NAMES=()
    SCRIPT_OPT_SPEC_PARAM_TYPES=()
    SCRIPT_OPT_SPEC_SHORT=''

    declare -i L=0
    declare -i N=${#SCRIPT_OPT_SPEC[@]-}
    declare -i OPT_SPEC_HAS_LONG=0

    while [ ${L} -lt ${N} ]
    do
        local OPT_NAME="${SCRIPT_OPT_SPEC[L]}"
        local OPT_TYPE=''
        local OPT_SPEC_INDEX=''

        case "${OPT_NAME}" in
        *=)
            OPT_TYPE='with-value'
            OPT_NAME="${OPT_NAME%=}"
            ;;
        *)
            OPT_TYPE='standalone'
            ;;
        esac

        declare -i OPT_SPEC_COUNT=${#SCRIPT_OPT_SPEC_PARAM_NAMES[@]-}

        [[ ${OPT_SPEC_COUNT} -gt 0 ]] && \
            OPT_SPEC_INDEX="$( indexOf "${OPT_NAME}" \
                "${SCRIPT_OPT_SPEC_PARAM_NAMES[@]-}" )"

        [[ "${OPT_SPEC_INDEX}" != '' ]] || {

            OPT_SPEC_INDEX=${OPT_SPEC_COUNT}
            SCRIPT_OPT_SPEC_PARAM_NAMES[OPT_SPEC_INDEX]="${OPT_NAME}"
        }

        SCRIPT_OPT_SPEC_PARAM_TYPES[OPT_SPEC_INDEX]="${OPT_TYPE}"

        if [ "${#OPT_NAME}" -ne 0 ]
        then
            if [ "${OPT_TYPE}" == 'standalone' ]
            then
                SCRIPT_OPT_SPEC_SHORT="${SCRIPT_OPT_SPEC_SHORT}${OPT_NAME}"
            else
                SCRIPT_OPT_SPEC_SHORT="${SCRIPT_OPT_SPEC_SHORT}${OPT_NAME}:"
            fi
        else
            OPT_SPEC_HAS_LONG=1
        fi

        let L+=1
    done

    if [ ${OPT_SPEC_HAS_LONG} -ne 0 ]
    then
        SCRIPT_OPT_SPEC_SHORT=":${SCRIPT_OPT_SPEC_SHORT}-:"
    else
        SCRIPT_OPT_SPEC_SHORT=":${SCRIPT_OPT_SPEC_SHORT}"
    fi
}

# For each command-line option passed to the script, invoke the pre-defined
# callback function to process the option.
function script_processOptions()
{
    isFunction script_processOption && {

        declare -i COUNT=0
        declare -i OPT_COUNT=${#SCRIPT_OPT_NAMES[@]-}

        while [ ${COUNT} -lt ${OPT_COUNT} ]
        do
            local OPT_NAME="${SCRIPT_OPT_NAMES[COUNT]}"
            local OPT_VALUE="${SCRIPT_OPT_VALUES[COUNT]}"
            let COUNT+=1

            script_processOption \
                "${COUNT}" "${OPT_NAME}" "${OPT_VALUE}" || return
        done
    }
}

# Show an error if an invalid option is specified.
function showErrorInvalidOption()
{
    local OPT_NAME="${1-}"
    local ERR_CODE="${2-}"

    {
        cat <<:ERROR
ERROR: An unsupported option was specified
OPTION: ${OPT_NAME}
:ERROR
        isFunction script_showUsage && script_showUsage hint
    } | \
        stderr "${ERR_CODE:-2}" || return
}

# Show an error if an option contains an invalid value.
function showErrorInvalidOptionValue()
{
    local OPT_NAME="${1}"
    local OPT_VALUE="${2}"
    local ERR_CODE="${3}"

    {
        cat <<:ERROR
ERROR: An invalid value was specified for an option
OPTION: ${OPT_NAME}
VALUE: ${OPT_VALUE}
:ERROR
        isFunction script_showUsage && script_showUsage hint
    } | \
        stderr "${ERR_CODE:-2}" || return
}

# Show an error if a required option is missing or empty.
function showErrorMissingOption()
{
    local OPT_NAME="${1}"
    local ERR_CODE="${2}"

    {
        cat <<:ERROR
ERROR: A required option was missing
OPTION: ${OPT_NAME}
:ERROR
        isFunction script_showUsage && script_showUsage hint
    } | \
        stderr "${ERR_CODE:-2}" || return
}
