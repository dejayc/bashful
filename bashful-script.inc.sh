#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Initialize the namespace presence indicator, and verify dependencies.
{
    declare BASHFUL_MODULE_SCRIPT='bashful-script.inc.sh'

    [[ -n "${BASHFUL_MODULE_OPTS}" ]] || {

        echo "Aborting loading of '${BASHFUL_MODULE_SCRIPT}':"
        echo "Dependency 'bashful-opts.inc.sh' is not loaded"
        exit 2
    } >&2
}

# Execute the script.
function bashful_script()
{
    # Execute the custom function 'script_validateRequirements', if it exists.
    isFunction script_validateRequirements && {

        # 'script_validateRequirements' is an optional function that should
        # validate basic requirements prior to executing the logic of this
        # script.  Example: verifying that this script has been invoked by a
        # super-user.
        script_validateRequirements || return
    }

    # Execute the custom function 'script_prepareParams', if it exists.
    isFunction script_prepareParams && {

        # 'script_prepareParams' is an optional function that should prepare
        # any script parameters prior to executing the logic of this script.
        # Example: initializing script parameters to default values.
        script_prepareParams || return
    }

    # If custom functions exist to handle command-line options, execute them.
    {
        # 'script_specifyOptions' is an optional function that should set the
        # array 'SCRIPT_OPT_SPEC' to be a list of command-line options that
        # are supported by this script.
        isFunction script_specifyOptions && {

            script_specifyOptions || return
        }

        # 'script_prepareOptions' is a function defined in 'bashful-opts' that
        # examines 'SCRIPT_OPT_SPEC' in preparation for parsing command-line
        # options passed to this script.
        isFunction script_prepareOptions && {

            script_prepareOptions || return
        }

        # 'script_parseOptions' is a function defined in 'bashful-opts' that
        # parses the command-line options passed to this script.
        isFunction script_parseOptions && {

            # Check the number of arguments so that some bash environments do
            # not generate an error when running under 'set -u'.
            if [ ${#@} -gt 0 ]
            then
                script_parseOptions "${@}" || return
            else
                script_parseOptions || return
            fi
        }

        # 'script_processOptions' is a function defined in 'bashful-opts' that
        # iterates through each of the command-line options passed to this
        # script, and invokes the optional function 'processScriptOption' for
        # each option.
        isFunction script_processOptions && {

            # Check the number of arguments so that some bash environments do
            # not generate an error when running under 'set -u'.
            if [ ${#@} -gt 0 ]
            then
                script_processOptions "${@}" || return
            else
                script_processOptions || return
            fi
        }
    }

    # Execute the custom function 'script_validateParams', if it exists.
    isFunction script_validateParams && {

        # 'script_validateParams' is an optional function that should validate
        # the parameters and command-line options passed to this script.
        # Example: validating that a specified input file exists.
        script_validateParams || return
    }

    # Execute the custom function 'script_validateEnvironment', if it exists.
    isFunction script_validateEnvironment && {

        # 'script_validateEnvironment' is an optional function that should
        # verify that the environment supports all functionality required by
        # this script.  This function is called after the script parameters
        # are validated, since the parameters may affect the functionality
        # executed by this script.  Example: verifying that required binary
        # utilities are present on the filesystem.
        script_validateEnvironment || return
    }

    # Execute the custom function 'script_execute', if it exists.
    isFunction script_execute && {

        # 'script_execute' is an optional function that executes the core logic
        # of this script, once all validation and command-line processing have
        # occurred.
        script_execute || return
    }
}

# If debugging is enabled, output the specified text to STDERR.
function ifDebug_stderr()
{
    declare -i CURRENT_STATUS_CODE=${?}
    local REQUIRED_DEBUG_LEVEL="${1}"
    local STATUS_CODE="${2}"

    [[ "${SCRIPT_DEBUG_LEVEL-0}" -ge "${REQUIRED_DEBUG_LEVEL-1}" ]] && {

        cat - 1>&2
    }

    return "${STATUS_CODE:-$CURRENT_STATUS_CODE}"
}

# If debugging is enabled, output the specified text to STDOUT.
function ifDebug_stdout()
{
    local REQUIRED_DEBUG_LEVEL="${1}"

    [[ "${SCRIPT_DEBUG_LEVEL-0}" -ge "${REQUIRED_DEBUG_LEVEL-1}" ]] && {

        cat -
    }
}

# Show usage information for the script.
function script_showUsage()
{
    local VARIATION="${1}"
    case "${VARIATION}" in
    full)
        isFunction script_showUsageSynopsis && script_showUsageSynopsis
        isFunction script_showUsageDetails && {

            echo
            script_showUsageDetails
        }
        ;;

    hint)
        isFunction script_showUsageHelpCommand && script_showUsageHelpCommand
        ;;

    synopsis)
        isFunction script_showUsageSynopsis && script_showUsageSynopsis
        ;;
    esac
}
