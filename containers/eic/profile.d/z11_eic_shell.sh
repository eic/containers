#!/bin/bash

## Prepend the eic-shell prefix to PATH and LD_LIBRARY_PATH, but only once.
if [ -n "${EIC_SHELL_PREFIX}" ]; then
  case ":${LD_LIBRARY_PATH}:" in
    *":${EIC_SHELL_PREFIX}/lib:"*) ;;
    *) export LD_LIBRARY_PATH="${EIC_SHELL_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" ;;
  esac
  case ":${PATH}:" in
    *":${EIC_SHELL_PREFIX}/bin:"*) ;;
    *) export PATH="${EIC_SHELL_PREFIX}/bin${PATH:+:${PATH}}" ;;
  esac
fi

## Disabled, as this causes issue with singularity which calls the script
## through sh instead of bash.
#set -uo pipefail
#trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
#IFS=$'\n\t'
#set -E
