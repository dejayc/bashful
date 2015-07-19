#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Declare the module name.
declare BASHFUL_MODULE='list'
declare BASHFUL_MODULE_DEPENDENCIES='text'

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

# function joinedList:
#
# Returns a separated list of items, with each item separated from the next
# by the specified output separator.  The list of items is constructed from
# each argument passed in to this function.
#
# -q optionally escapes each item being output, in a way that protects spaces,
#    quotes, and other special characters from being misinterpreted by the
#    shell.  Useful for assigning the output of this function to an array,
#    via the following construct:
#
#    declare -a ARRAY="( `joinedList -q "${INPUT_ARRAY[@]}"` )"
#
#    Note that while this option can be used simultaneously with an output
#    separator specified via -s, such usage is not guaranteed to be parsable,
#    depending upon the value of the separator.
#
# -s optionally specifies an output separator.  Defaults to ' '.
#
# -S optionally appends an output separator at the end of the output.  By
#    default, no output separator appears at the end of the output.  If an
#    output separator already exists at the end of the output because the
#    last item is null, an additional output separator will not be appended.
#
# Examples:
#
# $ joinedList -s ',' a b c d e
# a,b,c,d,e
#
# $ joinedList -s ';' -S a b c d e
# a;b;c;d;e;
#
# $ joinedList -s ',' a ''
# a,,
#
# $ joinedList -s ',' -S a ''
# a,,
#
# $ joinedList -s ',' '' ''
# ,,
#
# $ joinedList -q '' ''
# '' '' 
#
# $ joinedList -q 'hello there' 'my "friend"'
# hello\ there my\ \"friend\"
#
# $ joinedList -q -s ';' 'hello there' 'my "friend"'
# hello\ there;my\ \"friend\"
function joinedList()
{
    local SEP=' '
    declare -i TRAILING_SEP=0
    local FORMAT_STR='%s'

    # Parse function options.
    declare -i OPTIND
    local OPT=''

    while getopts ":qs:S" OPT
    do
        case "${OPT}" in
        q)
            FORMAT_STR='%q'
            ;;
        s)
            SEP="${OPTARG}"
            ;;
        S)
            let TRAILING_SEP=1
            ;;
        *)
            return 2
        esac
    done
    shift $(( OPTIND - 1 ))
    # Done parsing function options.

    declare -i COUNT=$#

    if [ ${COUNT} -gt 0 ]
    then
        declare -i TERMINAL_NULL=0

        [[ -n "${!COUNT}" ]] || {

            let TERMINAL_NULL=1
            let TRAILING_SEP=0 ||:
        }

        declare -i END=$(( TRAILING_SEP == 0 ? 1 : 0 ))
        while [ $# -gt ${END} ]
        do
            printf "${FORMAT_STR}%s" "${1}" "${SEP}"
            shift
        done

        if [ $# -gt 0 ]
        then
            printf "${FORMAT_STR}" "${1}"
        fi

        # If the final argument is null, append an extra separator, to be
        # consistent with the logic of splitList.
        if [ ${TERMINAL_NULL} -eq 1 ]
        then
            printf '%s' "${SEP}"
        fi
    fi
}

# function splitList:
#
# Splits one or more delimited lists, and outputs a list in which each item is
# escaped in a way that protects spaces, quotes, and other special characters
# from being misinterpreted by the shell.  Useful for assigning the output of
# this function to an array, via the following construct:
#
#    declare -a ARRAY="( `splitList 'arg1 arg2 arg3 etc.'` )"
#
# -d optionally specifies one or more input delimiter characters.  Defaults to
#    $IFS.  If null, splits every string into an array of characters.
#
# Examples:
#
# $ splitList -d ',' 'a,b' ',c'
# a b '' c
#
# $ splitList -d ',' 'a,'
# a
#
# $ splitList -d ',' 'a,,'
# a ''
#
# $ splitList -d ',' ',,'
# '' ''
#
# $ splitList -d ',' 'a,b,' ',c'
# a b '' c
#
# splitList -d ',' 'a,b,,' ',c'
# a b '' '' c
#
# $ splitList -d ',' 'hello,there' 'my "friend"'
# hello there my\ \"friend\"
#
# $ splitList -d '' 'hi there' 'bye'
# h i \  t h e r e b y e
function splitList()
{
    local DELIM="${IFS}"

    # Parse function options.
    declare -i OPTIND
    local OPT=''

    while getopts ":d:" OPT
    do
        case "${OPT}" in
        d)
            DELIM="${OPTARG}"
            ;;
        *)
            return 2
        esac
    done
    shift $(( OPTIND - 1 ))
    # Done parsing function options.

    local OUT=''

    declare -i TRIM_TRAIL_NL=0
    [[ "${DELIM}" =~ $'\n' ]] || let TRIM_TRAIL_NL=1

    while [ $# -gt 0 ]
    do
        local ARG="${1}"
        shift

        unset SET
        declare -a SET=()

        declare -i TRIM_TRAIL_NL=0
        [[ "${DELIM}" =~ $'\n' ]] || let TRIM_TRAIL_NL=1

        if [ -n "${DELIM}" ]
        then
            [[ ${TRIM_TRAIL_NL} -eq 0 ]] || {

                # Remove the trailing delimiter, if present, because otherwise
                # an empty array element will be created in the 'read' command
                # below, thanks to the newline appended by the here-string.
                ARG="${ARG%["${DELIM}"]}"
            }

            IFS="${DELIM}" read -r -d '' -a SET <<< "${ARG}"
        else
            while IFS='' read -r -d '' -n 1 CHAR
            do
                SET[${#SET[@]}]="${CHAR}"
            done <<< "${ARG}"
        fi

        declare -i SET_LEN=${#SET[@]-}

        [[ ${TRIM_TRAIL_NL} -eq 0 || ${SET_LEN} -eq 0 ]] || {

            # Remove the trailing newline that the here-string unhelpfully
            # appends in the above 'read' command.
            declare -i SET_LAST=$(( ${#SET[@]} - 1 ))

            if [ -n "${DELIM}" ]
            then
                SET[SET_LAST]="${SET[SET_LAST]%[[:space:]]}"
            else
                unset SET[SET_LAST]
            fi
        }

        local LIST
        printf -v LIST '%q ' "${SET[@]-}"
        printf -v OUT '%s%s' "${OUT}" "${LIST}"
    done
    printf '%s' "${OUT% }"
}

# function translatedList:
#
# Returns a list of items separated by the specified output separator,
# optionally trimming whitespace from items, removing duplicate entries,
# and/or outputting the list in reverse order, according to the flags
# specified.
#
# -l optionally trims leading whitespace from each set item.
#
# -n optionally preserves null items.
#
# -q optionally escapes each item being output, in a way that protects spaces,
#    quotes, and other special characters from being misinterpreted by the
#    shell.  Useful for assigning the output of this function to an array,
#    via the following construct:
#
#    declare -a ARRAY="( `translatedList -q "${INPUT_ARRAY[@]}"` )"
#
#    Note that while this option can be used simultaneously with an output
#    separator specified via -s, such usage is not guaranteed to be parsable,
#    depending upon the value of the separator.
#
# -r optionally processes the set in reverse order, outputting the set in
#    reverse order, and eliminating duplicate items in reverse order when -u
#    is specified.
#
# -s optionally specifies an output separator for each set item.  Defaults to
#    ' '.
#
# -S optionally appends an output separator at the end of the output.  By
#    default, no output separator appears at the end of the output.
#
# -t optionally trims trailing whitespace from each set item.
#
# -T optionally trims leading and trailing whitespace from each set item.
#
# -u optionally outputs only unique items, discarding duplicates from the
#    output.
#
# Examples:
#
# $ translatedList a b a c b d a
# a b a c b d a
#
# $ translatedList -r a b a c b d a
# a d b c a b a
#
# $ translatedList -u a b a c b d a
# a b c d
#
# $ translatedList -r -u a b a c b d a
# a d b c
#
# $ translatedList -s ';' -S a b a c b d a
# a;b;a;c;b;d;a;
#
# $ translatedList -l '[' '  leading' '  both  ' 'trailing  ' ']'
# [ leading both   trailing   ]
#
# $ translatedList -t '[' '  leading' '  both  ' 'trailing  ' ']'
# [   leading   both trailing ]
#
# $ translatedList -T '[' '  leading' '  both  ' 'trailing  ' ']'
# [ leading both trailing ]
#
# $ translatedList -l -t '[' '  leading' '  both  ' 'trailing  ' ']'
# [ leading both trailing ]
#
# $ translatedList -s ',' 1 2 '' 4 '' 5
# 1,2,4,5
#
# $ translatedList -s ',' -n 1 2 '' 4 '' 5
# 1,2,,4,,5
#
# $ translatedList -s ',' -n -u 1 2 '' 4 '' 5
# 1,2,,4,5
#
# $ translatedList -q 'hello there' 'my "friend"' '`whoami`'
# hello\ there my\ \"friend\" \`whoami\`
#
# $ translatedList -s ',' -q 'hello there' 'my "friend"'
# hello\ there,my\ \"friend\" \`whoami\`
function translatedList()
{
    local SEP=' '
    declare -i IS_REVERSED=0
    declare -i IS_LEAD_TRIMMED=0
    declare -i IS_TRAIL_TRIMMED=0
    declare -i IS_UNIQUE=0
    declare -i PRESERVE_NULL_ITEMS=0
    local FLAG_QUOTED=''
    local FLAG_TRAILING_SEP=''

    # Parse function options.
    declare -i OPTIND
    local OPT=''

    while getopts ':lnqrs:StTu' OPT
    do
        case "${OPT}" in
        d)
            DELIM="${OPTARG}"
            ;;
        l)
            let IS_LEAD_TRIMMED=1
            ;;
        n)
            let PRESERVE_NULL_ITEMS=1
            ;;
        q)
            FLAG_QUOTED="-${OPT}"
            ;;
        r)
            let IS_REVERSED=1
            ;;
        s)
            SEP="${OPTARG}"
            ;;
        S)
            FLAG_TRAILING_SEP="-${OPT}"
            ;;
        t)
            let IS_TRAIL_TRIMMED=1
            ;;
        T)
            let IS_LEAD_TRIMMED=1
            let IS_TRAIL_TRIMMED=1
            ;;
        u)
            let IS_UNIQUE=1
            ;;
        *)
            return 2
        esac
    done
    shift $(( OPTIND - 1 ))
    # Done parsing function options.

    local UNIQUE='|'
    local RESULTS=()

    if [ ${IS_REVERSED} -eq 0 ]
    then
        declare -i I=1
        declare -i STOP=$(( ${#} + 1 ))
        declare -i INC=1
    else
        declare -i I=${#}
        declare -i STOP=0
        declare -i INC=-1
    fi

    while [ ${I} -ne ${STOP} ]
    do
        local SET_MEMBER="${!I}"
        let I+=INC

        [[ ${IS_LEAD_TRIMMED} -eq 0 ]] || {

            SET_MEMBER="${SET_MEMBER#"${SET_MEMBER%%[![:space:]]*}"}"
        }

        [[ ${IS_TRAIL_TRIMMED} -eq 0 ]] || {

            SET_MEMBER="${SET_MEMBER%"${SET_MEMBER##*[![:space:]]}"}"
        }

        [[ -n "${SET_MEMBER}" || ${PRESERVE_NULL_ITEMS} -ne 0 ]] \
            || continue

        if [ ${IS_UNIQUE} -ne 0 ]
        then
            local UNIQUE_MEMBER

            # Perform CSV-like escaping of the '|' character so that
            # it can be used safely as an item delimiter within the
            # concatenated string of unique values   This is to
            # prevent item values with '|' from causing the unique
            # verification to report false positives.
            UNIQUE_MEMBER="${SET_MEMBER//\"/\"\"}"
            UNIQUE_MEMBER="${UNIQUE_MEMBER//|/\"|\"}"

            [[ "${UNIQUE}" =~ "|${UNIQUE_MEMBER}|" ]] && continue

            UNIQUE="${UNIQUE}${UNIQUE_MEMBER}|"
        fi

        printf -v SET_MEMBER '%s' "${SET_MEMBER}"
        RESULTS[${#RESULTS[@]}]="${SET_MEMBER}"
    done

    if [ ${#RESULTS[@]} -gt 0 ]
    then
        joinedList ${FLAG_QUOTED} -s "${SEP}" ${FLAG_TRAILING_SEP} \
            "${RESULTS[@]}"
    fi
}
