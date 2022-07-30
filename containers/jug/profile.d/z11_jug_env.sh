#!/bin/bash

export BINARY_TAG=x86_64-linux-gcc9-opt
if [ ! -z ${EIC_SHELL_PREFIX} ]; then
  if [  "$LD_LIBRARY_PATH" != *"${EIC_SHELL_PREFIX}/lib"* ]; then
    export LD_LIBRARY_PATH=$EIC_SHELL_PREFIX/lib:$LD_LIBRARY_PATH
    export PATH=$EIC_SHELL_PREFIX/bin:$PATH
  fi
fi

## Disabled, as this causes issue with singularity which calls the script
## through sh instead of bash.
#set -uo pipefail
#trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
#IFS=$'\n\t'
#set -E
