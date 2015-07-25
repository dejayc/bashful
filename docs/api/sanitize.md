# Bashful Module: `sanitize`

## Overview

**Purpose**: Provides an additional layer of safety when executing Bash scripts, by: disabling aliases or functions whose name conflicts with built-in keywords; and enabling shell options that perform additional safety checks.

**Unit Test Scripts**: No unit test scripts exist for `sanitize`. 

**Requires Modules**: None

**Required By Modules**: None

### Using `sanitize`

`sanitize` can be sourced by scripts to help protect against situations in which user-defined functions and aliases interfere with built-in Bash keywords.  Additional shell safety options are also enabled.  Sanitization is entirely optional, and does not require [`bashful.inc.sh`](../../bashful.inc.sh) to have been loaded first.

The calling script should execute the following statements to sanitize the script environment:

```
source "${0%/*}/bashful/bashful-sanitize.inc.sh" || exit 1
```

To be extra cautious against scenarios where the `source` keyword may have been overridden, execute the following statements:

```
POSIXLY_CORRECT=1 && builtin unset -f builtin source unset POSIXLY_CORRECT
source "${0%/*}/bashful/bashful-sanitize.inc.sh" || exit 1
```
