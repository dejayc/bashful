#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Requires:
#   bashful.inc.sh
#   bashful-litest.inc.sh
#   bashful-list.inc.sh
#   bashful-seq.inc.sh

# Include basic 'litest' functionality.
source "${0%/*}/../bashful.inc.sh" || exit
source "${BASHFUL_PATH}/bashful-litest.inc.sh" || exit

# Define script dependencies, loaded prior to test execution.
{
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-list.inc.sh" )
    TEST_SCRIPTS+=( "${BASHFUL_PATH}/bashful-seq.inc.sh" )
}

# Define global variables and constants.
{
    declare -r NL=$'\n'
}

# NOTE: Any occurrence of '&&:' in the source code is designed to preserve
# the $? status of a command while preventing the script from aborting if
# 'set -e' is active.


function testSpec_intseq()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
     $(( I++ )) )
        CMD="intSeq 2 03 4"
        OUT='2 03 4'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="intSeq 2 4 6 10-08"
        OUT='2 4 6 10 09 08'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="intSeq -u 5-8 10-6"
        OUT='5 6 7 8 10 9'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="intSeq -s ':' 1-5"
        OUT='1:2:3:4:5'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="intSeq -s ',' '1' '2' '' '4' '5' '  ' '6'"
        OUT='1,2,4,5,6'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="intSeq -s ',' -n '1' '2' '' '4' '5' '  ' '6'"
        OUT='1,2,,4,5,,6'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="intSeq -s ',' -n -u '1' '2' '' '4' '5' '  ' '6'"
        OUT='1,2,,4,5,6'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Multiple args; ranges; padding'
        CMD="intSeq '2 - 6' ' 1' ' 2  ' '  0-7 ' ' 4 ' 3 '05-10'"
        OUT='2 3 4 5 6 1 2 0 1 2 3 4 5 6 7 4 3 05 06 07 08 09 10'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Multiple args; ranges; padding; unique'
        CMD="intSeq -u '2 - 6' ' 1' ' 2  ' '  0-7 ' ' 4 ' 3 '05-10'"
        OUT='2 3 4 5 6 1 0 7 05 06 07 08 09 10'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Multiple args with padding and newlines'
        CMD="intSeq '1${NL}' ' 2${NL} ' 3 '4${NL}'"
        OUT='1 2 3 4'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Invalid characters'
        CMD="intSeq 1 a 3"
        OUT=''
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

function testSpec_nvseq()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="nameValueSeq 'a=1' 'b=2' 'c=3'"
        OUT='a=1;b=2;c=3'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq '=1' 'b=' 'c=3'"
        OUT='=1;b=;c=3'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -r '=1' 'b=' 'c=3'"
        OUT='=1;c=3'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -R '=1' 'b=' 'c=3'"
        OUT='b=;c=3'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq 'a=1' 'b'"
        OUT='a=1;b='
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -v 'a=1' 'b'"
        OUT='a=1;=b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -s ':' 'a=1' 'b=2' 'c=3'"
        OUT='a:1;b:2;c:3'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -S ',' 'a=1' 'b=2' 'c=3' 'd=4'"
        OUT='a=1,b=2,c=3,d=4'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -S ',' 'a=1' 'b=2' 'c=3'"
        OUT='a=1,b=2,c=3'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -u 'a=1' 'b=2' 'a=2' 'b=2'"
        OUT='a=1;b=2;a=2'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -t 'a= 1 ' 'b=2 ' 'c= 3'"
        OUT='a=1;b=2;c=3'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -T ' a =1' 'b =2' ' c=3'"
        OUT='a=1;b=2;c=3'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -d ':' 'url:http://example.com:80' 'val:start:stop'"
        OUT='url=http://example.com:80;val=start:stop'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq '[a,b]=[1,2]' '[c,d]=[3,4]'"
        OUT='a=1;a=2;b=1;b=2;c=3;c=4;d=3;d=4'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -s ',' -S ':' -b '[a,b]=[1,2]' '[c,d]=[3,4]'"
        OUT='[a,b],[1,2]:[c,d],[3,4]'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="nameValueSeq -S ' ' -q \"My Name=[No one,Doesn't matter]\""
        OUT="My\ Name=No\ one My\ Name=Doesn\'t\ matter"
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Pair separator'
        CMD="nameValueSeq -S ',' 'a=1' 'b=2' 'c=3'"
        OUT='a=1,b=2,c=3'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Value separator'
        CMD="nameValueSeq -s ':' 'a=1' 'b=2' 'c=3'"
        OUT='a:1;b:2;c:3'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Value delimiter'
        CMD="nameValueSeq -d ':' 'a:1' 'b:2' 'c:3'"
        OUT='a=1;b=2;c=3'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Name with integer permutations'
        CMD="nameValueSeq -d ':' 'HOST[1-3]:1'"
        OUT='HOST1=1;HOST2=1;HOST3=1'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Name with text permutations'
        CMD="nameValueSeq -d ':' 'HOST_[PORT,RANGE]:80'"
        OUT='HOST_PORT=80;HOST_RANGE=80'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Name with text permutations with newlines'
        CMD="nameValueSeq -d ':' 'section:${NL}[A:${NL},B:${NL}]value'"
        OUT="section=${NL}A:${NL}value;section=${NL}B:${NL}value"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Value with text permutations'
        CMD="nameValueSeq -d ':' 'HOST:192.168.0.[1-3]'"
        OUT='HOST=192.168.0.1;HOST=192.168.0.2;HOST=192.168.0.3'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Argument with newlines'
        CMD="nameValueSeq '[1${NL},${NL}2${NL}]=[a,b]'"
        OUT='1=a;1=b;2=a;2=b'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Null value delimiter'
        CMD="nameValueSeq -d '' 'a=1' 'b=2' 'c=3'"
        OUT=''
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

function testSpec_perseq()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="permutedSeq -s '; ' 'Trains depart at [1,09-10][am,pm]'"
        OUT=\
'Trains depart at 1am; Trains depart at 1pm; Trains depart at 09am; '\
'Trains depart at 09pm; Trains depart at 10am; Trains depart at 10pm'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSeq -m '<' -M '>' '<1,2,1><8,9>'"
        OUT='18 19 28 29 18 19'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSeq -u -m '<' -M '>' '<1,2,1><8,9>'"
        OUT='18 19 28 29'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSeq -s ',' '[sub,,super][script,,sonic]'"
        OUT='subscript,subsonic,superscript,supersonic'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSeq -s ',' -n '[sub,,super][script,,sonic]'"
        OUT='subscript,sub,subsonic,script,sonic,superscript,super,supersonic'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSeq -s ',' -N '[sub,,super][script,,sonic]'"
        OUT='subscript,sub,subsonic,script,,sonic,superscript,super,supersonic'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSeq -s ';' '[Hi,Bye], [world,you]' '[Regards,Thanks]'"
        OUT='Hi, world;Hi, you;Bye, world;Bye, you;Regards;Thanks'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSeq -q '[Hi,Bye] [there,you]'"
        OUT='Hi\ there Hi\ you Bye\ there Bye\ you'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSeq -s ':' -N '[,,]'"
        OUT='::'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='No args'
        CMD='permutedSeq'
        OUT=''
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Null text delimiter'
        CMD="permutedSeq -d ''"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Null opening delimiter'
        CMD="permutedSeq -m ''"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC="Invalid opening delimiter '-'"
        CMD="permutedSeq -m '-'"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Null closing delimiter'
        CMD="permutedSeq -M ''"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC="Invalid closing delimiter '-'"
        CMD="permutedSeq -M '-'"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Non-sequence arg'
        CMD="permutedSeq 'a,b,c,d'"
        OUT='a,b,c,d'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Number sequence'
        CMD="permutedSeq '[1,2]'"
        OUT='1 2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Number range'
        CMD="permutedSeq '[1-3]'"
        OUT='1 2 3'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Padded number range'
        CMD="permutedSeq '[01-3]'"
        OUT='01 02 03'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Descending number range'
        CMD="permutedSeq '[3-1]'"
        OUT='3 2 1'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Descending padded number range'
        CMD="permutedSeq '[3-01]'"
        OUT='03 02 01'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence single item'
        CMD="permutedSeq '[hello]'"
        OUT='hello'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence multiple items'
        CMD="permutedSeq '[hello,bye]'"
        OUT='hello bye'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence; matching text delim'
        CMD="permutedSeq -d ':' '[a:b]'"
        OUT='a b'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence; multiple text delims'
        CMD="permutedSeq -d ',;' '[a,b;c]'"
        OUT='a b c'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequences; non-matching text delim'
        CMD="permutedSeq -d ':' '[a b][c d]'"
        OUT='a bc d'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequences; matching text delim'
        CMD="permutedSeq -d ':' '[a:b][c:d]'"
        OUT='ac ad bc bd'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Separated text sequences'
        CMD="permutedSeq '[a,b], [c,d]'"
        OUT='a, c a, d b, c b, d'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Separated text sequences with output separator'
        CMD="permutedSeq -s ':' '[a,b], [c,d]'"
        OUT='a, c:a, d:b, c:b, d'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Number sequence with unique range'
        CMD="permutedSeq -u '[2-4,5-1]'"
        OUT='2 3 4 5 1'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with duplicates'
        CMD="permutedSeq '[a,b,a,c,b]'"
        OUT='a b a c b'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Unique text sequence'
        CMD="permutedSeq -u '[a,b,a,c,b]'"
        OUT='a b c'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with null items'
        CMD="permutedSeq '[a,,b,,c,,d]'"
        OUT='a b c d'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with preserved null items'
        CMD="permutedSeq -n '[a,,b][c,,d]'"
        OUT='ac a ad c d bc b bd'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with preserved null permutations'
        CMD="permutedSeq -N '[a,,b,,c,,d]'"
        OUT='a  b  c  d'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with preserved null permutations'
        CMD="permutedSeq -N '[a,,b][c,,d]'"
        OUT='ac a ad c  d bc b bd'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Numeric sequence without closing delimiter'
        CMD="permutedSeq '[1,2'"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Numeric sequence with mismatched closing delimiter'
        CMD="permutedSeq '[1,2['"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Numeric sequence without opening delimiter'
        CMD="permutedSeq '1,2]'"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Empty sequence'
        CMD="permutedSeq '[]'"
        OUT=''
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Embedded empty sequence'
        CMD="permutedSeq 'a[]b'"
        OUT='ab'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with opening delimiter'
        CMD="permutedSeq -m '<' '<a,b,c]'"
        OUT='a b c'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with closing delimiter'
        CMD="permutedSeq -M '>' '[a,b,c>'"
        OUT='a b c'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with opening and closing delimiters'
        CMD="permutedSeq -m '(' -M ')' '(a,b,c)'"
        OUT='a b c'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with multichar opening and closing delimiters'
        CMD="permutedSeq -m '<(' -M ')>' '(a,b,c)'"
        OUT='a b c'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequences with multichar opening and closing delimiters'
        CMD="permutedSeq -m '([' -M '])' '[1,a][2,b]'"
        OUT='12 1b a2 ab'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequences with reversed multichar delimiters'
        CMD="permutedSeq -m '])' -M '[(' ']1,a[]2,b['"
        OUT='12 1b a2 ab'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequences with switched multichar delimiters'
        CMD="permutedSeq -m '<(' -M ')>' '<1,a)(2,b>'"
        OUT='12 1b a2 ab'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with colliding opening and closing delimiters'
        CMD="permutedSeq -m '(' -M '(' '(a,b,c]'"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Text sequence with colliding opening and text delimiters'
        CMD="permutedSeq -m '(' -M '(' '(a(b(c]'"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Text sequence with colliding closing and text delimiters'
        CMD="permutedSeq -m ')' -M ')' '[a)b)c)'"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Text sequence with text delimiter'
        CMD="permutedSeq -d ',' '[a,b,c]'"
        OUT='a b c'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with preserved null perms'
        CMD="permutedSeq -s ':' -n -N '[a,,b][c,,d]'"
        OUT='ac:a:ad:c::d:bc:b:bd'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequence with preserved null perms and seps'
        CMD="permutedSeq -s ':' -n -N -p '[a,,b][c,,d]'"
        OUT='ac:a:ad:c::d:bc:b:bd'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Text sequences with preserved escaped characters'
        CMD="permutedSeq -s ',' '[Hi\\t,Bye\\t]my\\t[friend,foe]'"
        OUT='Hi\tmy\tfriend,Hi\tmy\tfoe,Bye\tmy\tfriend,Bye\tmy\tfoe'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two arguments with text sequences'
        CMD=\
"permutedSeq -s ';' -n '[Hi,Bye], [world,you]' '[Regards,Thanks]'"
        OUT='Hi, world;Hi, you;Bye, world;Bye, you;Regards;Thanks'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two arguments with unique sequences'
        CMD="permutedSeq -s ';' -u 'test [01-03]' 'test 0[3-5]'"
        OUT='test 01;test 02;test 03;test 04;test 05'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two arguments with unique sequences and preserve null perms'
        CMD="permutedSeq -s ';' -u -N '[1,,2]' '[a,,b]'"
        OUT='1;;2;a;b'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Argument with newlines'
        CMD="permutedSeq -d ',' -s ';' '[1${NL},${NL}2${NL}][a,b]'"
        OUT='1a;1b;2a;2b'
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

function testSpec_perset()
{
    TEST_CASE="${1-}"

    local DESC=''
    local CMD=''
    local OUT=''
    declare -i STAT=0
    declare -i I=1

    case "${TEST_CASE}" in
    $(( I++ )) )
        CMD="permutedSet '1 2' 'a b'"
        OUT='1 a 1 b 2 a 2 b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' '1,2' 'a,b'"
        OUT='1 a 1 b 2 a 2 b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -i ':' -s ',' '1 2' 'a b'"
        OUT='1:a,1:b,2:a,2:b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -i ':' -s ',' -S '1 2' 'a b'"
        OUT='1:a,1:b,2:a,2:b,'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' '1,,2' 'a,,b'"
        OUT='1 a,1 b,2 a,2 b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' -n '1,,2' 'a,,b'"
        OUT='1 a,1,1 b,a,b,2 a,2,2 b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' -p '1,,2' 'a,,b'"
        OUT='1 a,1,1 b,a,,b,2 a,2,2 b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' -N -p '1,,2' 'a,,b'"
        OUT='1 a,1 ,1 b, a, , b,2 a,2 ,2 b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' -n 'a big' 'bad,,' 'wolf'"
        OUT='a big bad wolf,a big wolf'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -n -q 'a big' 'bad,,' 'wolf'"
        OUT='a\ big\ bad\ wolf a\ big\ wolf'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -s ',' -n -q 'a big' 'bad,,' 'wolf'"
        OUT='a\ big\ bad\ wolf,a\ big\ wolf'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -i '' -s ',' -u '1,,2,,1' 'a,,b,,a'"
        OUT='1a,1b,2a,2b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -i '' -s ',' -u -n '1,,2,,1' 'a,,b,,a'"
        OUT='1a,1,1b,a,b,2a,2,2b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        CMD="permutedSet -d ',' -i '' -s ',' -u -p '1,,2,,1' 'a,,b,,a'"
        OUT='1a,1,1b,a,,b,2a,2,2b'
        DESC="Example: ${CMD}"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='No args'
        CMD='permutedSet'
        OUT=''
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Null delimiter'
        CMD="permutedSet -d ''"
        OUT=''
        let STAT=1
        ;;
    $(( I++ )) )
        DESC='Multiple delimiters'
        CMD="permutedSet -d ',;' 'a,b;c'"
        OUT='a b c'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='One arg'
        CMD="permutedSet 'a b'"
        OUT='a b'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='One arg with null item separator'
        CMD="permutedSet -i '' 'a b'"
        OUT='a b'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='One arg with item separator'
        CMD="permutedSet -i ':' 'a b'"
        OUT='a b'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with null item separator'
        CMD="permutedSet -i '' 'a b' '1 2'"
        OUT='a1 a2 b1 b2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with item separator'
        CMD="permutedSet -i ':' 'a b' '1 2'"
        OUT='a:1 a:2 b:1 b:2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with null perm separator'
        CMD="permutedSet -s '' 'a b' '1 2'"
        OUT='a 1a 2b 1b 2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with perm separator'
        CMD="permutedSet -i '' -s ':' 'a b' '1 2'"
        OUT='a1:a2:b1:b2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='One arg with delimiter'
        CMD="permutedSet -d ',' 'a,b'"
        OUT='a b'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with delimiter'
        CMD="permutedSet -i '' -d ',' 'a,b' '1,2'"
        OUT='a1 a2 b1 b2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with preserved null perms'
        CMD="permutedSet -i '' -d ',' -p 'a,,b' '1,,2'"
        OUT='a1 a a2 1  2 b1 b b2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with preserved null items'
        CMD="permutedSet -i '' -d ',' -n 'a,,b' '1,,2'"
        OUT='a1 a a2 1 2 b1 b b2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with preserved null items'
        CMD="permutedSet -i ':' -s ',' -d ',' -n 'a,,b' '1,,2'"
        OUT='a:1,a,a:2,1,2,b:1,b,b:2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with preserved null items and seps'
        CMD="permutedSet -i ':' -s ',' -d ',' -n -N 'a,,b' '1,,2'"
        OUT='a:1,a:,a:2,:1,:2,b:1,b:,b:2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with preserved null items, perms, and seps'
        CMD="permutedSet -i ':' -s ',' -d ',' -n -N -p 'a,,b' '1,,2'"
        OUT='a:1,a:,a:2,:1,:,:2,b:1,b:,b:2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Two args with unique filtering'
        CMD="permutedSet -u 'a b a' '1 2'"
        OUT='a 1 a 2 b 1 b 2'
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Argument with newlines'
        CMD="permutedSet -d ',' -s ';' '1${NL}2,3${NL}4'"
        OUT="1${NL}2;3${NL}4"
        let STAT=0 &&:
        ;;
    $(( I++ )) )
        DESC='Arguments with newlines'
        CMD="permutedSet -d ',' -i ':' -s ';' '1${NL}2,3${NL}4' 'a,b'"
        OUT="1${NL}2:a;1${NL}2:b;3${NL}4:a;3${NL}4:b"
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
