# Bashful
**Bashful**: A collection of handy helper functions for creating and unit-testing powerful and flexible Bash scripts.

## Overview

Bashful "modules" are Bash scripts that can be included directly within a calling Bash script.  Modules are grouped by, and named, according to the functionality contained within:

Module Name | Purpose
----------- | -------
[`bashful`](./docs/api/bashful.md) | Provides functions to: track and determine whether Bashful modules have been loaded; inspect the state of variables and functions; write output to `STDOUT` and `STDERR`.
[`error`](./docs/api/error.md) | Provides functions to generate error messages for common error scenarios.  
[`list`](./docs/api/list.md) | Provides functions to join, split, and translate lists of strings.
[`litest`](./docs/api/litest.md) | Provides a framework to execute one or more unit tests or performance tests for Bash script functions, reporting success, failure, and timing.
[`match`](./docs/api/match.md) | Provides functions to match wildcards within strings, and retrieve values for matching keys within a list of key/value pairs.
[`opts`](./docs/api/opts.md) | Provides a framework to allow Bash scripts to support short and long command-line option switches, by executing callbacks when encountering switches.
[`path`](./docs/api/path.md) | Provides functions to inspect and normalize filesystem paths.
[`sanitize`](./docs/api/sanitize.md) | Provides an additional layer of safety when executing Bash scripts, by: disabling aliases or functions whose name conflicts with built-in keywords; and enabling shell options that perform additional safety checks.
[`seq`](./docs/api/seq.md) | Provides functions to generate permutations of sequences and sets.
[`ssh-spec`](./docs/api/ssh-spec.md) | Provides functions to parse an advanced syntax that describes SSH connections, and the possible certificates and jump servers they might use.
[`text`](./docs/api/text.md) | Provides functions to trim and escape text representations.

## How to Load Modules

**NOTE**: All examples within this section assume that the Bashful library is located within a subdirectory named `bashful` relative to the calling script.

### Sourcing vs. Executing

Bashful modules are expected to be included within calling scripts by using the `source` or `.` keywords.  An error will be generated if Bashful modules are executed as scripts.

### Including [`bashful`](./docs/api/bashful.md)

Most Bashful modules require that [`bashful.inc.sh`](./bashful.inc.sh) is loaded first:
```
source "${0%/*}/bashful/bashful.inc.sh" || exit 1
```

### Helpful Bashful Variables

After loading [`bashful`](./docs/api/bashful.md), the following helpful variables are available to facilitate the loading of other modules and scripts:

Variable Name | Purpose
------------- | -------
<a name='bashful_version'></a>`BASHFUL_VERSION` | The Bashful version number
<a name='bashful_path'></a>`BASHFUL_PATH` | The path in which Bashful modules are located
<a name='script_invoked_name'></a>`SCRIPT_INVOKED_NAME` | The path and name of the calling script
<a name='script_name'></a>`SCRIPT_NAME` | The name of the calling script
<a name='script_invoked_path'></a>`SCRIPT_INVOKED_PATH` | The path of the calling script
<a name='script_run_date'></a>`SCRIPT_RUN_DATE` | The date and time at which the script included Bashful
<a name='script_debug_level'></a>`SCRIPT_DEBUG_LEVEL` | A script debugging level variable that can be used to determine whether certain types of output get echoed to the TTY

### Conditionally Loading Modules

It is a best practice to only load a Bashful module if it hasn't already been loaded.  Nonetheless, each Bashful module checks to see if it has already been loaded, and if it has, returns out of the module without re-executing the logic within.

To conditionally load [`bashful`](./docs/api/bashful.md), first check to see if the variable [`BASHFUL_VERSION`](#bashful_version) is empty:

```
[[ -n "${BASHFUL_VERSION:-}" ]] || \
    source "${0%/*}/bashful/bashful.inc.sh" || exit 1

```

Once [`bashful`](./docs/api/bashful.md) has been loaded, the function [`isModuleLoaded`](./docs/api/bashful.md#ismoduleloaded) can be executed to verify whether a specific module has been loaded.  In the following example, the module [`opts`](./docs/api/opts.md) will be loaded conditionally :

```
isModuleLoaded 'opts' || \
    source "${BASHFUL_PATH}/bashful-opts.inc.sh" || exit 1
```

### Verifying Module Dependencies

Bashful modules track dependencies so that calling scripts can fail themselves if required modules haven't been loaded.  To do so, execute the function [`verifyBashfulDependencies`](./docs/api/bashful.md#verifybashfuldependencies):

```
verifyBashfulDependencies || exit
```

### Using [`sanitize`](./docs/api/sanitize.md)

[`sanitize`](./docs/api/sanitize.md) can be sourced by scripts to help protect against situations in which user-defined functions and aliases interfere with built-in Bash keywords.  Additional shell safety options are also enabled.  Sanitization is entirely optional, and does not require [`bashful.inc.sh`](./bashful.inc.sh) to have been loaded first.

The calling script should execute the following statements to sanitize the script environment:

```
source "${0%/*}/bashful/bashful-sanitize.inc.sh" || exit 1
```

To be extra cautious against scenarios where the `source` keyword may have been overridden, execute the following statements:

```
POSIXLY_CORRECT=1 && builtin unset -f builtin source unset POSIXLY_CORRECT
source "${0%/*}/bashful/bashful-sanitize.inc.sh" || exit 1
```

## Bashful Unit Tests

Bashful comes with the following unit test scripts to verify the majority of functionality within its modules:

Script Name | Purpose
----------- | -------
[`tests/all.sh`](./tests/all.sh) | Executes every unit test script within Bashful
[`tests/list.sh`](./tests/list.sh) | Executes unit test cases for the [`list`](./docs/api/list.md) module
[`tests/match.sh`](./tests/match.sh) | Executes unit test cases for the [`match`](./docs/api/match.md) module
[`tests/seq.sh`](./tests/seq.sh) | Executes unit test cases for the [`seq`](./docs/api/seq.md) module
[`tests/sshs.sh`](./tests/sshs.sh) | Executes unit test cases for the [`ssh-spec`](./docs/api/ssh-spec.md) module
[`tests/text.sh`](./tests/text.sh) | Executes unit test cases for the [`text`](./docs/api/text.md) module

## Module Dependencies

Module Name | Script | Requires | Required By
----------- | ------ | -------- | -----------
[`bashful`](./docs/api/bashful.md) | [`bashful.inc.sh`](./bashful.inc.sh) | None | [`error`](./docs/api/error.md), [`opts`](./docs/api/opts.md)
[`error`](./docs/api/error.md) | [`bashful-error.inc.sh`](./bashful-error.inc.sh) | [`bashful`](./docs/api/bashful.md) | None
[`list`](./docs/api/list.md) | [`bashful-list.inc.sh`](./bashful-list.inc.sh) | [`text`](./docs/api/text.md) | [`match`](./docs/api/match.md), [`seq`](./docs/api/seq.md), [`ssh-spec`](./docs/api/ssh-spec.md)
[`litest`](./docs/api/litest.md) | [`bashful-litest.inc.sh`](./bashful-litest.inc.sh) | None | None
[`match`](./docs/api/match.md) | [`bashful-match.inc.sh`](./bashful-match.inc.sh) | [`list`](./docs/api/list.md), [`text`](./docs/api/text.md) | [`ssh-spec`](./docs/api/ssh-spec.md)
[`opts`](./docs/api/opts.md) | [`bashful-opts.inc.sh`](./bashful-opts.inc.sh) | [`bashful`](./docs/api/bashful.md) | None
[`path`](./docs/api/path.md) | [`bashful-path.inc.sh`](./bashful-path.inc.sh) | None | None
[`sanitize`](./docs/api/sanitize.md) | [`bashful-sanitize.inc.sh`](./bashful-sanitize.inc.sh) | None | None
[`seq`](./docs/api/seq.md) | [`bashful-seq.inc.sh`](./bashful-seq.inc.sh) | [`list`](./docs/api/list.md) | [`ssh-spec`](./docs/api/ssh-spec.md)
[`ssh-spec`](./docs/api/ssh-spec.md) | [`bashful-ssh-spec.inc.sh`](./bashful-ssh-spec.inc.sh) | [`list`](./docs/api/list.md), [`match`](./docs/api/match.md), [`seq`](./docs/api/seq.md) | None
[`text`](./docs/api/text.md) | [`bashful-text.inc.sh`](./bashful-text.inc.sh) | None | [`list`](./docs/api/list.md), [`match`](./docs/api/match.md)

Functionality from version 1.1.2 of `bash-script-lib` has been migrated to this project.

Copyright 2009-2016 Dejay Clayton.  All rights reserved.
