#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Initialize the namespace presence indicator.
{
    declare BASHFUL_MODULE_ENV='bashful-env.inc.sh'
}

function isScriptSshCommand()
{
    [[ "$(ps -o comm= -p $PPID)" =~ 'sshd' ]]
}
