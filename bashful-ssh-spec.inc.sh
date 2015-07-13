#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Initialize the namespace presence indicator, and verify dependencies.
{
    declare BASHFUL_MODULE_SSH_SPEC='bashful-ssh-spec.inc.sh'

    [[ -n "${BASHFUL_MODULE_LIST-}" ]] || {

        echo "Aborting loading of '${BASHFUL_MODULE_SSH_SPEC}':"
        echo "Dependency 'bashful-list.inc.sh' is not loaded"
        exit 2
    } >&2

    [[ -n "${BASHFUL_MODULE_SEQ-}" ]] || {

        echo "Aborting loading of '${BASHFUL_MODULE_SSH_SPEC}':"
        echo "Dependency 'bashful-seq.inc.sh' is not loaded"
        exit 2
    } >&2

    [[ -n "${BASHFUL_MODULE_MATCH-}" ]] || {

        echo "Aborting loading of '${BASHFUL_MODULE_SSH_SPEC}':"
        echo "Dependency 'bashful-match.inc.sh' is not loaded"
        exit 2
    } >&2
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
# 'ssh-host' and 'ssh-param' mirrors the list of SSH hosts passed into the
# function, with duplicates removed.  'ssh-cert', 'ssh-jump-host', and
# 'ssh-jump-host-cert' designate which, if any, SSH certificate, SSH jump
# host, and SSH jump host certificate will be used to connect to the
# destination SSH host.  These values are determined by the arguments passed
# to this function, described below.
#
# Each value is quoted, in a way that protects spaces, quotes, and other
# special characters from being misinterpreted by the shell.  This format is
# useful for assigning the output of this function to an array, via the
# following construct:
#
#    declare -a ARRAY="( `parsedSshSpecs ...` )"
#
# The data passed to this function consists of the following delimited lists:
# a list of SSH hosts mapped to custom parameters; a list of SSH hosts mapped
# to SSH jump hosts; and a list of SSH hosts mapped to SSH certificates.
#
# The semicolon-separated ';' list of SSH hosts passed to this function
# contains entries in the following format:
#
#   ssh-user@ssh-host:ssh-param
#
# 'ssh-user@' is optional, but 'ssh-host' is required.  'ssh-param' is also
# optional, and can be used to specify an important parameter associated with
# the SSH host; for example, it can contain an SCP destination path, a shell
# command to execute on the SSH host, a TCP port number, etc.
#
# Note that if 'ssh-param' needs to contain a semicolon ';' character, a list
# delimiter other than semicolon can be specified with the '-d' switch.
# Specifying a delimiter in this way affects only this argument, and not the
# others, which always use semicolon as a delimiter.
#
# 'ssh-host' may contain permutation sequences, as defined by function
# 'permutedSeq' in 'bashful-seq'.  Such permutations will be permuted and
# combined with 'ssh-user' and 'ssh-param' to form a list of multiple SSH
# connections.  This can be useful when a list of SSH connections needs to be
# calculated from a series of IP addresses or subdomains.  For example, host
# '[www,app][1-3].example.com' would be permuted into 'www1.example.com',
# 'www2.example.com', 'www3.example.com', 'app1.example.com',
# 'app2.example.com', and 'app3.example.com'.
#
# For more information about permutation sequences, please refer to function
# 'permutedSeq' in 'bashful-seq'.
#
# The semicolon-separated ';' list of SSH certificates passed to this function
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
# The semicolon-separated ';' list of SSH jump hosts passed to this function
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
# -d optionally specifies one or more delimiter characters, used to separate
#    the delimited list mapping SSH hosts to parameters.  Defaults to ';'.  An
#    error is returned if null, or if it contains '[', ']', or '-' characters.
#    Note that all other delimited lists will use semicolon ';' as the
#    delimiter.
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
#
# $ parsedSshSpecs -d ',' 'example.com: uname -a; ls -al;,' \
#   'www.example.com: uname -a; whoami;'
# example.com uname\ -a\;\ ls\ -al\; '' '' '' \
# www.example.com uname\ -a\;\ whoami\; '' '' ''
function parsedSshSpecs()
{
    local DELIM=';'

    # Parse function options.
    declare -i OPTIND
    local OPT=''

    while getopts ":d:" OPT
    do
        case "${OPT}" in
        d)
            DELIM="${OPTARG}"
            [[ -z "${DELIM}" || "${DELIM}" =~ [][-] ]] && return 1
            ;;
        *)
            return 2
        esac
    done
    shift $(( OPTIND - 1 ))
    # Done parsing function options.

    local HOSTS_DLIST="${1-}"
    local CERTS_DLIST="${2-}"
    local JUMP_HOSTS_DLIST="${3-}"

    [[ -n "${HOSTS_DLIST}" ]] || return 0

    local HOSTS_LIST
    HOSTS_LIST="$( \
permutedSshSpec -d "${DELIM}" "${HOSTS_DLIST}" )" || return

    [[ -n "${HOSTS_LIST}" ]] || return 0

    declare -a HOSTS="( ${HOSTS_LIST} )" || return
    declare -i HOSTS_LEN=${#HOSTS[@]}
    [[ ${HOSTS_LEN} -gt 0 ]] || return 0

    local CERTS_LIST=''
    declare -a CERTS=()
    declare -i CERTS_LEN=0

    if [ -n "${CERTS_DLIST}" ]
    then
        CERTS_LIST="$( permutedSshSpec -d ';' "${CERTS_DLIST}" )" || return

        [[ -n "${CERTS_LIST}" ]] && {

            declare -a CERTS="( ${CERTS_LIST} )" || return
            let CERTS_LEN=${#CERTS[@]} ||:
        }
    fi

    local JUMP_HOSTS_LIST=''
    declare -a JUMP_HOSTS=()
    declare -i JUMP_HOSTS_LEN=0

    if [ -n "${JUMP_HOSTS_DLIST}" ]
    then
        JUMP_HOSTS_LIST="$( \
permutedSshSpec -d ';' "${JUMP_HOSTS_DLIST}" )" || return

        [[ -n "${JUMP_HOSTS_LIST}" ]] && {

            declare -a JUMP_HOSTS="( ${JUMP_HOSTS_LIST} )" || return
            let JUMP_HOSTS_LEN=${#JUMP_HOSTS[@]} ||:
        }
    fi

    declare -i I=0
    while [ ${I} -lt ${HOSTS_LEN} ]
    do
        local ENTRY="${HOSTS[I]}"
        let I++

        [[ "${ENTRY}" =~ ^((([^@]+)@)?([^@:]+))(:(.*))?$ ]] || return

        local SSH_HOST="${BASH_REMATCH[1]-}"
        local SSH_PARAM="${BASH_REMATCH[6]-}"

        local JUMP_HOST=''
        [[ ${JUMP_HOSTS_LEN} -gt 0 ]] && {

            JUMP_HOST="$( \
                valueForMatchedSshHost "${SSH_HOST}" "${JUMP_HOSTS[@]}" )"
        }

        local JUMP_HOST_CERT=''
        local CERT=''

        [[ ${CERTS_LEN} -gt 0 ]] && {

            JUMP_HOST_CERT="$( \
                valueForMatchedSshHost "${JUMP_HOST}" "${CERTS[@]}" )"

            CERT="$( \
                valueForMatchedSshHost "${SSH_HOST}" "${CERTS[@]}" )"
        }

        printf '%q ' \
            "${SSH_HOST}" "${SSH_PARAM}" "${CERT}" \
            "${JUMP_HOST}" "${JUMP_HOST_CERT}"
    done
}

# function permutedSshSpec:
#
# Returns a list of mappings, where each mapping consists of an SSH host
# mapped to some relevant parameter.
#
# Each mapping is quoted, in a way that protects spaces, quotes, and other
# special characters from being misinterpreted by the shell.  This format is
# useful for assigning the output of this function to an array, via the
# following construct:
#
#    declare -a ARRAY="( `permutedSshSpec ...` )"
#
# The data passed to this function consists of a delimited list of SSH hosts
# mapped to some relevant parameter.  By default, entries in the list are
# separated by semicolon ';' character, and adhere to the following format:
#
#   ssh-user@ssh-host:ssh-param
#
# 'ssh-user@' is optional, but 'ssh-host' is required.  'ssh-param' is also
# optional, and can be used to specify an important parameter associated with
# the SSH host; for example, it can contain an SCP destination path, a shell
# command to execute on the SSH host, a TCP port number, etc.
#
# Note that if 'ssh-param' needs to contain a semicolon ';' character, a list
# delimiter other than semicolon can be specified with the '-d' switch.
#
# 'ssh-host' may contain permutation sequences, as defined by function
# 'permutedSeq' in 'bashful-seq'.  Such permutations will be permuted and
# combined with 'ssh-user' and 'ssh-param' to form a list of multiple SSH
# connections.  This can be useful when a list of SSH connections needs to be
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
# -d optionally specifies one or more delimiter characters, used to separate
#    the delimited list mapping SSH hosts to parameters.  Defaults to ';'.  An
#    error is returned if null, or if it contains '[', ']', or '-' characters.
#
# Examples:
#
# $ permutedSshSpec '[www,app][1-3]: /ftp;'
# www1:/ftp www2:/ftp www3:/ftp app1:/ftp app2:/ftp app3:/ftp
#
# $ permutedSshSpec -d ',' 'www[1-2]: uname -a; ls -al;,www: uname -a,'
# www1:uname\ -a\;\ ls\ -al\; www2:uname\ -a\;\ ls\ -al\; www:uname\ -a
function permutedSshSpec()
{
    local DELIM=';'

    # Parse function options.
    declare -i OPTIND
    local OPT=''

    while getopts ":d:" OPT
    do
        case "${OPT}" in
        d)
            DELIM="${OPTARG}"
            [[ -z "${DELIM}" || "${DELIM}" =~ [][-] ]] && return 1
            ;;
        *)
            return 2
        esac
    done
    shift $(( OPTIND - 1 ))
    # Done parsing function options.

    local ENTRIES_DLIST="${1-}"

    [[ -n "${ENTRIES_DLIST}" ]] || return 0

    local ENTRIES_LIST
    ENTRIES_LIST="$( splitList -d "${DELIM}" "${ENTRIES_DLIST}" )" || return

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

        [[ \
"${ENTRY}" =~ ^${WS}((([^@]+)@)?([^@:]+))(${WS}:${WS}(.*)${WS})?$ ]] || return

        local SSH_USER="${BASH_REMATCH[3]-}"
        local SSH_HOST="${BASH_REMATCH[4]-}"
        local SSH_PARAM="${BASH_REMATCH[6]-}"

        unset SSH_HOSTS

        # Check to see if the SSH host has permutations, and if so, permute
        # them.
        if [[ "${SSH_HOST}" =~ ["${LB}"] ]]
        then
            local SSH_HOSTS_LIST
            SSH_HOSTS_LIST="$( permutedSeq -u -q "${SSH_HOST}" )" || return

            [[ -n "${SSH_HOSTS_LIST}" ]] || {

                echo -n "${SSH_HOST}"
                return 1
            }

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

            local SSH_HOST_PARAM="${SSH_HOST}:${SSH_PARAM}"

            [[ -n "${SSH_USER}" ]] && {

                SSH_HOST_PARAM="${SSH_USER}@${SSH_HOST_PARAM}"
            }

            SSH_HOST_PARAMS[${#SSH_HOST_PARAMS[@]}]="${SSH_HOST_PARAM}"
        done
    done

    if [ ${#SSH_HOST_PARAMS[@]} -gt 0 ]
    then
        translatedList -n -u -q -t "${SSH_HOST_PARAMS[@]}"
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
# colon ':' character.
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
# $ valueForMatchedSshHost user@10.1.1.1 10.1.*:ten-one
# ten-one
#
# $ valueForMatchedSshHost user@10.2.1.1 10.1.*:ten-one user@10.*:user-ten
# user-ten
function valueForMatchedSshHost()
{
    local SSH_HOST="${1-}"

    [[ -n "${SSH_HOST}" ]] || return 0
    shift

    local VALUE="$( valueForMatchedName -d ':' -w "${SSH_HOST}" "${@}" )" ||:

    # If no matching value was found for the SSH host, and the SSH host has an
    # SSH user included, remove the SSH user and try again, in order to detect
    # matches with parameters that specify SSH hosts with no SSH user.
    [[ -z "${VALUE}" && "${SSH_HOST}" =~ @ ]] && {

        VALUE="$( valueForMatchedName -d ':' -w "${SSH_HOST##*@}" "${@}" )" ||:
    }

    echo -n "${VALUE}"
}
