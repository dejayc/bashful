#!/bin/bash

# Bashful is copyright 2009-2015 Dejay Clayton, all rights reserved:
#     https://github.com/dejayc/bashful
# Bashful is licensed under the 2-Clause BSD License:
#     http://opensource.org/licenses/BSD-2-Clause

# Bashful error code ranges:
#         0: Success
#         1: General script error
#         2: Usage error or help; or error executing built-in command
#   3 -  19: Error codes returned from utilities and shell
#  20 -  39: A required parameter was missing
#  40 -  59: A specified parameter was invalid
#  60 -  79: A resource specified by a parameter was missing
#  80 -  99: A resource specified by a parameter was invalid 
# 100 - 119: A required configuration setting was missing
# 120 - 139: Reserved for special shell exit codes
#       126: A command was not executable, due to permission or file issues
# 140 - 159: A specified configuration setting was invalid
# 160 - 169: A resource specified by a configuration setting was missing 
# 180 - 199: A resource specified by a configuration setting was invalid
# 200 - 219: An internal script error occurred

# Default bash error codes:
# (please refer to http://www.tldp.org/LDP/abs/html/exitcodes.html)
#         0: Success
#         1: General script error
#         2: Usage error or help; or error executing built-in command
#       126: A command was not executable, due to permission or file issues
#       127: An illegal command was specified
#       128: Exit status was out of range
# 128 - 255: An error signal of (128 + n) was encountered. E.g. kill -9 = 137
#       130: Execution was terminated via Ctrl-C (128 + 2)
#       255: Exit status was out of range
