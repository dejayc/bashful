# Bashful Module: `opts`

## Overview

**Purpose**: Provides a framework to allow Bash scripts to support short and long command-line option switches, by executing callbacks when encountering switches.

**Unit Test Scripts**: No unit test scripts exist for `opts`. 

**Requires Modules**: [`bashful`](./docs/api/bashful.md)

**Required By Modules**: None

## Using `opts` within Scripts

Adding advanced handling of short options (e.g. `-h`), long options (e.g. `--help`), with values (e.g. `-l file`, `--log file`, `--log=file`) and without, to Bash scripts is made easy with the `opts` module.

### Specifying `SCRIPT_OPT_SPEC`

`opts` declares a global array variables named `SCRIPT_OPT_SPEC`.  Assign values to it to indicate the options to be supported by the Bash script:
```
SCRIPT_OPT_SPEC=(
    'h' 'help'
    'l=' 'log='
    'v' 'verbose'
)
```

Options ending with `=` represent options that require a mandatory value to be supplied following the option.  Note that short options supplied to the script on the command line **must** be separated from their values by whitespace (e.g. `-l file`); whereas long options may be separated from their values by either whitespace (e.g. `--log file`) or equal `=` (e.g. `--log=file`).  This limitation regarding short options is due to the Bash convention that allows several short options to be concatenated together (e.g. `-h -v` is equivalent to `-hv`).

Options that lack a mandatory value will cause an error to be generated.  Options that are supplied to the script on the command line, but do not appear specified within `SCRIPT_OPT_SPEC`, are considered to be invalid options, and will cause an error to be generated.

### Specifying `processScriptOption`

`opt` requires that the calling script provide a function named `processScriptOption`, whose purpose is to be invoked as a callback whenever a script option is successfully processed.  `processScriptOptions` typically sets internal script variables based upon the script options that were processed.

`processScriptOption` should be defined similar to the following:
```
function processScriptOption()
{
    local OPT_COUNT="${1}"
    local OPT_NAME="${2}"
    local OPT_VALUE="${3}"

    # Do something with the above variables.
}
```

In the example above: `OPT_COUNT` represents the ordinal offset of the option being processed; `OPT_NAME` represents the name of the option; and `OPT_VALUE` represents the value passed to the option, if the option requires a value.

### Processing Script Options

After `SCRIPT_OPT_SPEC` and `processScriptOption` have been defined, the calling script may begin to process the command line options passed to the script, by invoking the function `prepareScript` as follows:

```
prepareScript \
    "${#SCRIPT_OPT_SPEC[@]}" "${SCRIPT_OPT_SPEC[@]}" "${@:+${@}}" \
    || return
```

If `processScriptOption` does not exist as a function within the calling script, `prepareScript` will return a non-success status value.

### Best Practices

It is recommended that `processScriptOption` actually populate an array of the options that were received, rather than acting upon them immediately.  After `prepareScript` successfully returns, the calling script can then validate the array of options, and iterate through them to process them in order.  This provides a few benefits:

* If the script specifies that a certain flag should cause help text to be displayed, it is usually desired that the script should **ONLY** display the help text, and not begin to perform any other script logic.  Since actual logic isn't executed within the function `processScriptOption`, receiving a `help` option could cause the script to display help text and terminate, before any actual logic had the chance of being executed.
* Validation can be performed upon all of options simultaneously, instead of handling them piecemeal within `processScriptOption`.  This can allow redundant or out-of-order arguments to be handled sensibly.

When passing the command line arguments from one function to another, it is recommended to use the notation `"${@:+${@}}"`, which will not generate an error if no command line arguments are specified and `set -u` is defined.
