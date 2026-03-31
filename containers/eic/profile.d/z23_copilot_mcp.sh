#!/bin/sh

## Seed default Copilot MCP server configuration from system template.
## Only runs if the system template exists and the user does not yet
## have a ~/.copilot/mcp-config.json (first-login convenience).
## This is necessary for Singularity/Apptainer users where the home
## directory is mounted from the host and cannot be pre-populated in
## the container image.

if [ -f /etc/copilot/mcp-config.json ] && [ ! -f "${HOME}/.copilot/mcp-config.json" ]; then
  mkdir -p "${HOME}/.copilot" &&
  cp /etc/copilot/mcp-config.json "${HOME}/.copilot/mcp-config.json"
fi
