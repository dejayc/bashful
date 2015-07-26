# Bashful Module: `ssh-spec`

## Overview

**Purpose**: Provides functions to parse an advanced syntax that describes SSH connections, and the possible certificates and jump servers they might use.

**Unit Test Scripts**: [`tests/sshs.sh`](../../tests/sshs.sh) provides unit tests for the `ssh-spec` module. 

Unit Test Group | Description
--------------- | -----------
`parspec` | Unit tests for function [`parsedSshSpecs`](#function-parsedsshspecs)
`permap` | Unit tests for function [`permutedSshMap`](#function-permutedsshmap)
`valhost` | Unit tests for function [`valueForMatchedSshHost`](#function-valueformatchedsshhost)
`valhosts` | Unit tests for function [`valuesForMatchedSshHosts`](#function-valuesformatchedsshhosts)

**Requires Modules**: [`list`](./list.md), [`match`](./match.md), [`seq`](./seq.md)

**Required By Modules**: None

## Global Variables

Variable Name | Purpose
------------- | -------
<a name='bashful_loaded_ssh_spec'></a>`BASHFUL_LOADED_ssh_spec` | Declares that `ssh_spec` has been loaded

## Functions

### Function Index

Function Name | Description
------------- | -----------
[`parsedSshSpecs`](#function-parsedsshspecs) | Returns a series of connection parameters that represents one or more SSH connections, based upon multiple criteria passed to this function.  Useful for scripts that need to established elaborate SSH connections.
[`permutedSshMap`](#function-permutedsshmap) | Returns a map, where each map entry consists of an SSH host descriptor mapped to some relevant parameter.
[`valueForMatchedSshHost`](#function-valueformatchedsshhost) | From a series of passed arguments that represent mappings between SSH host descriptors and arbitrary values, returns the value from the first mapping whose SSH host descriptor matches the specified SSH host.  The first argument passed to this function is interpreted as the SSH host to search for.  All subsequent arguments are interpreted as mappings between SSH host descriptors and arbitrary values.
[`valuesForMatchedSshHosts`](#function-valuesformatchedsshhosts) | Accepts as the first argument a delimited map of SSH host descriptors mapped to parameter values; and as a series of subsequent arguments, a list of SSH hosts; and for each SSH host in the list, returns the corresponding value that is mapped to the first SSH host descriptor that matches the host.

### Function API

#### Function: `parsedSshSpecs`

**Description**: Returns a series of connection parameters that represents one or more SSH connections, based upon multiple criteria passed to this function.  Useful for scripts that need to established elaborate SSH connections.

The data returned by this function consists of the following sequence of values, repeated for each incoming SSH host that is passed in to this function:

`ssh-host ssh-param ssh-cert ssh-jump-host ssh-jump-host-cert`

`ssh-host` and `ssh-param` mirrors the map of SSH hosts passed into the function, with duplicates removed.  `ssh-cert`, `ssh-jump-host`, and `ssh-jump-host-cert` designate which, if any, SSH certificate, SSH jump host, and SSH jump host certificate will be used to connect to the destination SSH host.  These values are determined by the arguments passed to this function, described below.

Each value is escaped, in a way that protects spaces, quotes, and other special characters from being misinterpreted by the shell.  This format is useful for assigning the output of this function to an array, via the following construct:
```
declare -a ARRAY="( `parsedSshSpecs ...` )"
```
The data passed to this function consists of the following delimited maps: a map of SSH hosts mapped to custom parameters; a map of SSH hosts mapped to SSH jump hosts; and a map of SSH hosts mapped to SSH certificates.

The semicolon-separated `;` map of SSH hosts passed to this function contains entries in the following format:

`ssh-user@ssh-host:ssh-param`

`ssh-user@` is optional, but `ssh-host` is required.  `ssh-param` is also optional, and can be used to specify an important parameter associated with the SSH host; for example, it can contain an SCP destination path, a shell command to execute on the SSH host, a TCP port number, etc.  Since the semi-colon `;` character is used to delimit the map of SSH hosts, any literal semi-colon characters that must appear within `ssh-param` must be escaped by prefixing it with backslash `\`, as `\;`.

`ssh-host` may contain permutation sequences, as defined by function [`permutedSeq`](./seq.md#function-permutedseq) in [`bashful-seq`](./seq.md).  Such permutations will be permuted and combined with `ssh-user` and `ssh-param` to form a map of multiple SSH connections.  This can be useful when a map of SSH connections needs to be calculated from a series of IP addresses or subdomains.  For example, host `[www,app][1-3].example.com` would be permuted into `www1.example.com`, `www2.example.com`, `www3.example.com`, `app1.example.com`, `app2.example.com`, and `app3.example.com`.

For more information about permutation sequences, please refer to function [`permutedSeq`](./seq.md#function-permutedseq) in [`bashful-seq`](./seq.md).

The semicolon-separated `;` map of SSH certificates passed to this function designates any optional SSH certificates that must be used to connect to the destination SSH hosts.  Each entry consists of a name/value pair in the following format:

`ssh-user@ssh-host:path-to-certificate`

`ssh-host` is a specifier that matches one or more SSH hosts.  `ssh-user@` is optional, and if present, will only match hosts that contain the specified `ssh-user`.

`ssh-user` and `ssh-host` may contain wildcards.  Question mark `?` is a wildcard that matches exactly one occurrence of any character.  Asterisk `*` matches zero or more characters.  For example, `user@*.example.com` matches any subdomain of `example.com`.

Any whitespace around names or values is trimmed.  `ssh-host` may also contain permutation sequences, as defined above, which themselves may contain wildcards.

The semicolon-separated `;` map of SSH jump hosts passed to this function designates any optional SSH jump hosts that must be used to connect to the destination SSH hosts.  Each entry consists of a name/value pair in the following format:

`ssh-user@ssh-host:ssh-jump-user@ssh-jump-host`

Similar to other SSH settings described above, `ssh-user@` is optional, and `ssh-user` and `ssh-host` may contain wildcards.  `ssh-host` may also contain permutation sequences.  Any whitespace around names or values is trimmed.

**Examples**:
```
parsedSshSpecs '10.1.1.1: /ftp;'
10.1.1.1 /ftp '' '' ''

parsedSshSpecs 'user@10.[1,2].1.1: /ftp;' 'user@10.*: /home/cert;'
user@10.1.1.1 /ftp /home/cert '' '' \
user@10.2.1.1 /ftp /home/cert '' ''

parsedSshSpecs 'user@10.[1,2].1.1: /ftp;' \
    'user@10.1.*: /home/cert1; user@10.2.*: /home/cert2;'
user@10.1.1.1 /ftp /home/cert1 '' '' \
user@10.2.1.1 /ftp /home/cert2 '' ''

parsedSshSpecs 'user@10.[1,2].1.1: /ftp;' \
    '10.3.*: /home/jump; *: /home/cert;' '10.2.*: 10.3.1.1;'
user@10.1.1.1 /ftp /home/cert '' '' \
user@10.2.1.1 /ftp /home/cert 10.3.1.1 /home/jump
```

#### Function: `permutedSshMap`

**Description**: Returns a map, where each map entry consists of an SSH host descriptor mapped to some relevant parameter.

Each map entry is escaped, in a way that protects spaces, quotes, and other special characters from being misinterpreted by the shell.  This format is useful for assigning the output of this function to an array, via the following construct:
```
declare -a ARRAY="( `permutedSshMap ...` )"
```
The data passed to this function consists of a delimited map of SSH host descriptors mapped to some relevant parameter, in the following format:

`ssh-user@ssh-host:ssh-param`

Entries in the map are separated by semicolon `;` character.  If `ssh-param` must contain semi-colons, the required semi-colons can be escaped by prefixing them with the backslash `\` character, as `\;`.

`ssh-user@` is optional, but `ssh-host` is required.  `ssh-param` is also optional, and can be used to specify an important parameter associated with the SSH host; for example, it can contain an SCP destination path, a shell command to execute on the SSH host, a TCP port number, etc.

`ssh-host` may contain permutation sequences, as defined by function [`permutedSeq`](./seq.md#function-permutedseq) in [`bashful-seq`](./seq.md).  Such permutations will be permuted and combined with `ssh-user` and `ssh-param` to form a map of multiple SSH connections.  This can be useful when a map of SSH connections needs to be calculated from a series of IP addresses or subdomains.  For example, host `[www,app][1-3].example.com` would be permuted into `www1.example.com`, `www2.example.com`, `www3.example.com`, `app1.example.com`, `app2.example.com`, and `app3.example.com`.

For more information about permutation sequences, please refer to function
[`permutedSeq`](./seq.md#function-permutedseq) in [`bashful-seq`](./seq.md).

Any whitespace around names or values is trimmed.

**Examples**:
```
permutedSshMap '[www,app][1-3]: /ftp;'
www1:/ftp www2:/ftp www3:/ftp app1:/ftp app2:/ftp app3:/ftp

permutedSshMap '[www,app][1-3] : /ftp ;'
www1:/ftp www2:/ftp www3:/ftp app1:/ftp app2:/ftp app3:/ftp

permutedSshMap 'host1: uname -a\; ls -al\;;host2: pwd\;;'
host1:uname\ -a\;\ ls\ -al\; host2:pwd\;
```

#### Function: `valueForMatchedSshHost`

**Description**: From a series of passed arguments that represent mappings between SSH host descriptors and arbitrary values, returns the value from the first mapping whose SSH host descriptor matches the specified SSH host.  The first argument passed to this function is interpreted as the SSH host to search for.  All subsequent arguments are interpreted as mappings between SSH host descriptors and arbitrary values.

SSH host descriptors are separated from their corresponding values by a colon `:` character.  Whitespace is trimmed from SSH host descriptors and their values.

SSH host descriptors may contain wildcards.  Question mark `?` is a wildcard that matches exactly one occurrence of any character.  Asterisk `*` matches zero or more characters.

If no SSH host descriptor matches the specified SSH host, and the SSH host includes an SSH user, the search will be performed again without the SSH user.  This allows SSH host descriptors to match if they only contain a domain, and not SSH user.

**Examples**:
```
valueForMatchedSshHost 'user@10.1.1.1' '10.1.*:ten-one'
ten-one

valueForMatchedSshHost 'user@10.2.1.1' \
    '10.1.*:ten-one' 'user@10.*:user-ten'
user-ten

valueForMatchedSshHost 'user@10.2.1.1' \
    ' 10.1.* : ten-one ' ' user@10.* : user-ten '
user-ten
```

#### Function: `valuesForMatchedSshHosts`

**Description**: Accepts as the first argument a delimited map of SSH host descriptors mapped to parameter values; and as a series of subsequent arguments, a list of SSH hosts; and for each SSH host in the list, returns the corresponding value that is mapped to the first SSH host descriptor that matches the host.

Each value is escaped, in a way that protects spaces, quotes, and other special characters from being misinterpreted by the shell.  This format is useful for assigning the output of this function to an array, via the following construct:
```
declare -a ARRAY="( `valuesForMatchedSshHosts ...` )"
```
In the map argument passed to this function, SSH host descriptors are separated from their corresponding values by the colon `:` character, and are separated from each other via the semi-colon `;` character.  Whitespace is trimmed from the SSH host descriptors and their values.

SSH host descriptors may contain wildcards.  Question mark `?` is a wildcard that matches exactly one occurrence of any character.  Asterisk `*` matches zero or more characters.

If no SSH host descriptor matches a particular SSH host, and the SSH host includes an SSH user, the search will be performed again without the SSH user.  This allows SSH host descriptors to match if they only contain a domain, and not SSH user.

**Examples**:
```
valuesForMatchedSshHosts '10.1.*:ten-one' 'user@10.1.1.1'
ten-one

valuesForMatchedSshHosts \
    '10.1.*:ten-one; user@10.*:user-ten' 'user@10.2.1.1' '10.1.1.1'
user-ten ten-one

valuesForMatchedSshHosts \
    ' 10.1.* : ten-one ; user@10.* : user-ten' 'user@10.2.1.1' '10.1.1.1'
user-ten ten-one
```
