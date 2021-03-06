#!/bin/bash

# Bashful is copyright 2009-2016 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Declare the module name and dependencies.
declare BASHFUL_MODULE='ssh_spec'
declare BASHFUL_MODULE_DEPENDENCIES='list match seq'

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

# NOTE: Any occurrence of '&&:' and '||:' that appears following a command is
# designed to prevent that command from terminating the script when a non-zero
# status is returned while 'set -e' is active.  This is especially necessary
# with the 'let' command, which if used to assign '0' to a variable, is
# treated as a failure.  '&&:' preserves the $? status of a command.  '||:'
# discards the status, which is useful when the last command of a function
# returns a non-zero status, but should not cause the function to be
# considered as a failure.


# function parsedSshSpecs:
#
# Returns a series of connection parameters that represents one or more SSH
# connections, based upon multiple criteria passed to this function.  Useful
# for scripts that need to established elaborate SSH connections.
#
# The data returned by this function consists of the following sequence of
# values, repeated for each incoming SSH host that is passed in to this
# function:
#
#   ssh-host ssh-param ssh-cert ssh-jump-host ssh-jump-host-cert
#
# 'ssh-host' and 'ssh-param' mirrors the map of SSH hosts passed into the
# function, with duplicates removed.  'ssh-cert', 'ssh-jump-host', and
# 'ssh-jump-host-cert' designate which, if any, SSH certificate, SSH jump
# host, and SSH jump host certificate will be used to connect to the
# destination SSH host.  These values are determined by the arguments passed
# to this function, described below.
#
# Each value is escaped, in a way that protects spaces, quotes, and other
# special characters from being misinterpreted by the shell.  This format is
# useful for assigning the output of this function to an array, via the
# following construct:
#
#    declare -a ARRAY="( `parsedSshSpecs ...` )"
#
# The data passed to this function consists of the following delimited maps:
# a map of SSH hosts mapped to custom parameters; a map of SSH hosts mapped
# to SSH jump hosts; and a map of SSH hosts mapped to SSH certificates.
#
# The semicolon-separated ';' map of SSH hosts passed to this function
# contains entries in the following format:
#
#   ssh-user@ssh-host:ssh-param
#
# 'ssh-user@' is optional, but 'ssh-host' is required.  'ssh-param' is also
# optional, and can be used to specify an important parameter associated with
# the SSH host; for example, it can contain an SCP destination path, a shell
# command to execute on the SSH host, a TCP port number, etc.  Since the
# semi-colon ';' character is used to delimit the map of SSH hosts, any
# literal semi-colon characters that must appear within 'ssh-param' must be
# escaped by prefixing it with backslash '\', as '\;'.
#
# 'ssh-host' may contain permutation sequences, as defined by function
# 'permutedSeq' in 'bashful-seq'.  Such permutations will be permuted and
# combined with 'ssh-user' and 'ssh-param' to form a map of multiple SSH
# connections.  This can be useful when a map of SSH connections needs to be
# calculated from a series of IP addresses or subdomains.  For example, host
# '[www,app][1-3].example.com' would be permuted into 'www1.example.com',
# 'www2.example.com', 'www3.example.com', 'app1.example.com',
# 'app2.example.com', and 'app3.example.com'.
#
# For more information about permutation sequences, please refer to function
# 'permutedSeq' in 'bashful-seq'.
#
# The semicolon-separated ';' map of SSH certificates passed to this function
# designates any optional SSH certificates that must be used to connect to the
# destination SSH hosts.  Each entry consists of a name/value pair in the
# following format:
#
#   ssh-user@ssh-host:path-to-certificate
#
# 'ssh-host' is a specifier that matches one or more SSH hosts.  'ssh-user@'
# is optional, and if present, will only match hosts that contain the
# specified 'ssh-user'.
#
# 'ssh-user' and 'ssh-host' may contain wildcards.  Question mark '?' is a
# wildcard that matches exactly one occurrence of any character.  Asterisk '*'
# matches zero or more characters.  For example, 'user@*.example.com' matches
# any subdomain of 'example.com'.
#
# Any whitespace around names or values is trimmed.  'ssh-host' may also
# contain permutation sequences, as defined above, which themselves may
# contain wildcards.
#
# The semicolon-separated ';' map of SSH jump hosts passed to this function
# designates any optional SSH jump hosts that must be used to connect to the
# destination SSH hosts.  Each entry consists of a name/value pair in the
# following format:
#
#   ssh-user@ssh-host:ssh-jump-user@ssh-jump-host
#
# Similar to other SSH settings described above, 'ssh-user@' is optional, and
# 'ssh-user' and 'ssh-host' may contain wildcards.  'ssh-host' may also
# contain permutation sequences.  Any whitespace around names or values is
# trimmed.
#
# Examples:
#
# $ parsedSshSpecs '10.1.1.1: /ftp;'
# 10.1.1.1 /ftp '' '' ''
#
# $ parsedSshSpecs 'user@10.[1,2].1.1: /ftp;' 'user@10.*: /home/cert;'
# user@10.1.1.1 /ftp /home/cert '' '' \
# user@10.2.1.1 /ftp /home/cert '' ''
#
# $ parsedSshSpecs 'user@10.[1,2].1.1: /ftp;' \
#   'user@10.1.*: /home/cert1; user@10.2.*: /home/cert2;'
# user@10.1.1.1 /ftp /home/cert1 '' '' \
# user@10.2.1.1 /ftp /home/cert2 '' ''
#
# $ parsedSshSpecs 'user@10.[1,2].1.1: /ftp;' \
#   '10.3.*: /home/jump; *: /home/cert;' '10.2.*: 10.3.1.1;'
# user@10.1.1.1 /ftp /home/cert '' '' \
# user@10.2.1.1 /ftp /home/cert 10.3.1.1 /home/jump
function parsedSshSpecs()
{
    local PARAMS_DMAP="${1-}"
    local CERTS_DMAP="${2-}"
    local JUMP_HOSTS_DMAP="${3-}"

    local PARAMS_LIST
    PARAMS_LIST="$( permutedSshMap "${PARAMS_DMAP}" )" || return
    declare -a PARAMS="( ${PARAMS_LIST} )" || return
    declare -i PARAMS_LEN=${#PARAMS[@]}
    [[ ${PARAMS_LEN} -gt 0 ]] || return 0

    declare -a HOSTS=()
    declare -a PATHS=()

    declare -i I=0
    while [ ${I} -lt ${PARAMS_LEN} ]
    do
        [[ "${PARAMS[I]}" =~ ^((([^@]+)@)?([^@:]+))(:(.*))?$ ]] || return

        HOSTS[I]="${BASH_REMATCH[1]-}"
        PATHS[I]="${BASH_REMATCH[6]-}"
        let I++
    done

    local CERTS_LIST=''
    CERTS_LIST="$( \
valuesForMatchedSshHosts "${CERTS_DMAP}" "${HOSTS[@]}" )" || return
    declare -a CERTS="( ${CERTS_LIST} )" || return

    local JUMP_HOSTS_LIST=''
    JUMP_HOSTS_LIST="$( \
valuesForMatchedSshHosts "${JUMP_HOSTS_DMAP}" "${HOSTS[@]}" )" \
        || return
    declare -a JUMP_HOSTS="( ${JUMP_HOSTS_LIST} )" || return

    local JUMP_HOSTS_CERTS_LIST=''
    JUMP_HOSTS_CERTS_LIST="$( \
valuesForMatchedSshHosts "${CERTS_DMAP}" "${JUMP_HOSTS[@]}" )" \
        || return
    declare -a JUMP_HOSTS_CERTS="( ${JUMP_HOSTS_CERTS_LIST} )" || return

    declare -i I=0
    while [ ${I} -lt ${PARAMS_LEN} ]
    do
        printf '%q ' \
            "${HOSTS[I]}" "${PATHS[I]}" "${CERTS[I]}" \
            "${JUMP_HOSTS[I]}" "${JUMP_HOSTS_CERTS[I]}"
        let I++
    done ||:
}

# function permutedSshMap:
#
# Returns a map, where each map entry consists of an SSH host descriptor
# mapped to some relevant parameter.
#
# Each map entry is escaped, in a way that protects spaces, quotes, and other
# special characters from being misinterpreted by the shell.  This format is
# useful for assigning the output of this function to an array, via the
# following construct:
#
#    declare -a ARRAY="( `permutedSshMap ...` )"
#
# The data passed to this function consists of a delimited map of SSH host
# descriptors mapped to some relevant parameter, in the following format:
#
#   ssh-user@ssh-host:ssh-param
#
# Entries in the map are separated by semicolon ';' character.  If 'ssh-param'
# must contain semi-colons, the required semi-colons can be escaped by
# prefixing them with the backslash '\' character, as '\;'.
#
# 'ssh-user@' is optional, but 'ssh-host' is required.  'ssh-param' is also
# optional, and can be used to specify an important parameter associated with
# the SSH host; for example, it can contain an SCP destination path, a shell
# command to execute on the SSH host, a TCP port number, etc.
#
# 'ssh-host' may contain permutation sequences, as defined by function
# 'permutedSeq' in 'bashful-seq'.  Such permutations will be permuted and
# combined with 'ssh-user' and 'ssh-param' to form a map of multiple SSH
# connections.  This can be useful when a map of SSH connections needs to be
# calculated from a series of IP addresses or subdomains.  For example, host
# '[www,app][1-3].example.com' would be permuted into 'www1.example.com',
# 'www2.example.com', 'www3.example.com', 'app1.example.com',
# 'app2.example.com', and 'app3.example.com'.
#
# For more information about permutation sequences, please refer to function
# 'permutedSeq' in 'bashful-seq'.
#
# Any whitespace around names or values is trimmed.
#
# Examples:
#
# $ permutedSshMap '[www,app][1-3]: /ftp;'
# www1:/ftp www2:/ftp www3:/ftp app1:/ftp app2:/ftp app3:/ftp
#
# $ permutedSshMap '[www,app][1-3] : /ftp ;'
# www1:/ftp www2:/ftp www3:/ftp app1:/ftp app2:/ftp app3:/ftp
#
# $ permutedSshMap 'host1: uname -a\; ls -al\;;host2: pwd\;;'
# host1:uname\ -a\;\ ls\ -al\; host2:pwd\;
function permutedSshMap()
{
    local ENTRIES_DMAP="${1-}"
    [[ -n "${ENTRIES_DMAP}" ]] || return 0

    local ENTRIES_LIST
    ENTRIES_LIST="$( splitList -d ';' -e "${ENTRIES_DMAP}" )" || return
    [[ -n "${ENTRIES_LIST}" ]] || return

    declare -a SSH_HOST_PARAMS=()
    declare -a ENTRIES="( ${ENTRIES_LIST} )" || return
    declare -i ENTRIES_LEN="${#ENTRIES[@]}"
    declare -i I=0

    # The following variable exists to prevent various bash shell versions,
    # and even syntax highlighting in different text editors, from becoming
    # confused due to discrepancies in how they handle regex literals.
    local LB='['

    # The following variable just makes regexes easier to read.
    local WS='[[:space:]]*'

    while [ ${I} -lt ${ENTRIES_LEN} ]
    do
        local ENTRY="${ENTRIES[I]}"
        let I++

        [[ "${ENTRY}" =~ ^[[:space:]]*$ ]] && continue

        [[ "${ENTRY}" =~ ^${WS}((([^@]+)@)?([^@:]+))(:${WS}(.*))?$ ]] \
            || return

        local SSH_USER="${BASH_REMATCH[3]-}"
        local SSH_HOST="${BASH_REMATCH[4]-}"
        SSH_HOST="${SSH_HOST%"${SSH_HOST##*[![:space:]]}"}"
        local SSH_PARAM="${BASH_REMATCH[6]-}"

        unset SSH_HOSTS

        # Check to see if the SSH host has permutations, and if so, permute
        # them.
        if [[ "${SSH_HOST}" =~ ["${LB}"] ]]
        then
            local SSH_HOSTS_LIST
            SSH_HOSTS_LIST="$( permutedSeq -u -q "${SSH_HOST}" )" || return

            if [ -z "${SSH_HOSTS_LIST}" ]
            then
                echo -n "${SSH_HOST}"
                return 1
            fi

            declare -a SSH_HOSTS="( ${SSH_HOSTS_LIST} )" || return
        else
            declare -a SSH_HOSTS=( "${SSH_HOST}" ) || return
        fi

        declare -i SSH_HOSTS_LEN=${#SSH_HOSTS[@]}
        declare -i J=0

        while [ ${J} -lt ${SSH_HOSTS_LEN} ]
        do
            SSH_HOST="${SSH_HOSTS[J]}"
            let J++

            if [ -n "${SSH_USER}" ]
            then
                local SSH_HOST_PARAM="${SSH_USER}@${SSH_HOST}:${SSH_PARAM}"
            else
                local SSH_HOST_PARAM="${SSH_HOST}:${SSH_PARAM}"
            fi

            SSH_HOST_PARAMS[${#SSH_HOST_PARAMS[@]}]="${SSH_HOST_PARAM}"
        done
    done

    if [ ${#SSH_HOST_PARAMS[@]} -gt 0 ]
    then
        translatedList -n -u -q -T "${SSH_HOST_PARAMS[@]}"
    fi
}

# function valueForMatchedSshHost:
#
# From a series of passed arguments that represent mappings between SSH host
# descriptors and arbitrary values, returns the value from the first mapping
# whose SSH host descriptor matches the specified SSH host.  The first
# argument passed to this function is interpreted as the SSH host to search
# for.  All subsequent arguments are interpreted as mappings between SSH host
# descriptors and arbitrary values.
#
# SSH host descriptors are separated from their corresponding values by a
# colon ':' character.  Whitespace is trimmed from SSH host descriptors and
# their values.
#
# SSH host descriptors may contain wildcards.  Question mark '?' is a
# wildcard that matches exactly one occurrence of any character.  Asterisk '*'
# matches zero or more characters.
#
# If no SSH host descriptor matches the specified SSH host, and the SSH host
# includes an SSH user, the search will be performed again without the SSH
# user.  This allows SSH host descriptors to match if they only contain a
# domain, and not SSH user.
#
# Examples:
#
# $ valueForMatchedSshHost 'user@10.1.1.1' '10.1.*:ten-one'
# ten-one
#
# $ valueForMatchedSshHost 'user@10.2.1.1' \
#   '10.1.*:ten-one' 'user@10.*:user-ten'
# user-ten
#
# $ valueForMatchedSshHost 'user@10.2.1.1' \
#   ' 10.1.* : ten-one ' ' user@10.* : user-ten '
# user-ten
function valueForMatchedSshHost()
{
    local SSH_HOST="${1-}"

    [[ -n "${SSH_HOST}" ]] || return 0
    shift

    local VALUE="$( \
valueForMatchedName -d ':' -w -t "${SSH_HOST}" "${@}" )" ||:

    # If no matching value was found for the SSH host, and the SSH host has an
    # SSH user included, remove the SSH user and try again, in order to detect
    # matches with parameters that specify SSH hosts with no SSH user.
    if [[ -z "${VALUE}" && "${SSH_HOST}" =~ @ ]]
    then
        VALUE="$( \
valueForMatchedName -d ':' -w -t "${SSH_HOST##*@}" "${@}" )" ||:
    fi

    echo -n "${VALUE}"
}

# function valuesForMatchedSshHosts:
#
# Accepts as the first argument a delimited map of SSH host descriptors mapped
# to parameter values; and as a series of subsequent arguments, a list of SSH
# hosts; and for each SSH host in the list, returns the corresponding value
# that is mapped to the first SSH host descriptor that matches the host.
#
# Each value is escaped, in a way that protects spaces, quotes, and other
# special characters from being misinterpreted by the shell.  This format is
# useful for assigning the output of this function to an array, via the
# following construct:
#
#    declare -a ARRAY="( `valuesForMatchedSshHosts ...` )"
#
# In the map argument passed to this function, SSH host descriptors are
# separated from their corresponding values by the colon ':' character, and
# are separated from each other via the semi-colon ';' character.  Whitespace
# is trimmed from the SSH host descriptors and their values.
#
# SSH host descriptors may contain wildcards.  Question mark '?' is a
# wildcard that matches exactly one occurrence of any character.  Asterisk '*'
# matches zero or more characters.
#
# If no SSH host descriptor matches a particular SSH host, and the SSH host
# includes an SSH user, the search will be performed again without the SSH
# user.  This allows SSH host descriptors to match if they only contain a
# domain, and not SSH user.
#
# Examples:
#
# $ valuesForMatchedSshHosts '10.1.*:ten-one' 'user@10.1.1.1'
# ten-one
#
# $ valuesForMatchedSshHosts \
#   '10.1.*:ten-one; user@10.*:user-ten' 'user@10.2.1.1' '10.1.1.1'
# user-ten ten-one
#
# $ valuesForMatchedSshHosts \
#   ' 10.1.* : ten-one ; user@10.* : user-ten' 'user@10.2.1.1' '10.1.1.1'
# user-ten ten-one
function valuesForMatchedSshHosts()
{
    local PARAMS_DMAP="${1-}"
    shift

    local PARAMS_LIST=''
    declare -a PARAMS=()
    declare -i PARAMS_LEN=0

    if [ -n "${PARAMS_DMAP}" ]
    then
        PARAMS_LIST="$( permutedSshMap "${PARAMS_DMAP}" )" || return

        if [ -n "${PARAMS_LIST}" ]
        then
            declare -a PARAMS="( ${PARAMS_LIST} )" || return
            let PARAMS_LEN=${#PARAMS[@]} ||:
        fi
    fi

    declare -a VALUES=()

    while [ $# -gt 0 ]
    do
        local SSH_HOST="${1-}"
        shift

        local VALUE=''
        if [ ${PARAMS_LEN} -gt 0 ]
        then
            VALUE="$( valueForMatchedSshHost "${SSH_HOST}" "${PARAMS[@]}" )"
        fi

        VALUES[${#VALUES[@]}]="${VALUE}"
    done

    printf '%q ' "${VALUES[@]}"
}
