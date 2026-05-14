#!/bin/sh

## Set COPILOT_CUSTOM_INSTRUCTIONS_DIRS to /etc/copilot so github-copilot
## reads custom instructions with a pointer to MCP server configuration.
##
## To revert to ~/.copilot (or any other directory), add the following
## to your ~/.bashrc:
##   unset COPILOT_CUSTOM_INSTRUCTIONS_DIRS

if [ -z "${COPILOT_CUSTOM_INSTRUCTIONS_DIRS:-}" ]; then
  export COPILOT_CUSTOM_INSTRUCTIONS_DIRS=/etc/copilot
else
  case "$-" in
    *i*) printf '%s\n' "Note: COPILOT_CUSTOM_INSTRUCTIONS_DIRS is already set to '${COPILOT_CUSTOM_INSTRUCTIONS_DIRS}'; not overriding with /etc/copilot." >&2 ;;
  esac
fi
