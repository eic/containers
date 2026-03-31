#!/bin/sh

## Set COPILOT_HOME to /etc/copilot so github-copilot reads MCP server
## configuration directly from the system-level config, rather than from
## ~/.copilot. This works for Singularity/Apptainer users whose home
## directory is bind-mounted from the host at runtime.
##
## To revert to ~/.copilot (or any other directory), add the following
## to your ~/.bashrc:
##   unset COPILOT_HOME

if [ -z "${COPILOT_HOME:-}" ]; then
  export COPILOT_HOME=/etc/copilot
else
  echo "Note: COPILOT_HOME is already set to '${COPILOT_HOME}'; not overriding with /etc/copilot."
fi
