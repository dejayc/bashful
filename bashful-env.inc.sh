#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Initialize the namespace presence indicator.
{
    declare BASHFUL_MODULE_ENV='bashful-env.inc.sh'
}

# Initialize global variables.
{
    # Determine if the script is interactive.
    declare -i SCRIPT_IS_INTERACTIVE=0
    [[ "${-}" =~ 'i' ]] && SCRIPT_IS_INTERACTIVE=1

    # Determine if the script was sourced.
    declare -i SCRIPT_IS_SOURCED=0
    [[ "${BASH_ARGV}" != '' ]] && SCRIPT_IS_SOURCED=1

    # Determine if the script was executed via an SSH command.
    declare -i SCRIPT_IS_SSH_COMMAND=0
    [[ "$(ps -o comm= -p $PPID)" =~ 'sshd' ]] && SCRIPT_IS_SSH_COMMAND=1

    true # true prevents 'set -e' from aborting
}

function isScriptInteractive()
{
    (( ${SCRIPT_IS_INTERACTIVE} ))
}

function isScriptSourced()
{
    (( ${SCRIPT_IS_SOURCED} ))
}

function isScriptSshCommand()
{
    (( ${SCRIPT_IS_SSH_COMMAND} ))
}
