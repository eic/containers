#!/bin/bash

## Prepend the eic-shell prefix to PATH and LD_LIBRARY_PATH, but only once.
##
## This file is re-sourced by every login shell, so an unguarded prepend makes
## both variables grow without bound across nested eic-shell invocations.
##
## The guard uses `case` rather than `[[ ... ]]`: singularity sources this
## script through sh (see the note below), where bash conditional expressions
## are unavailable.  Note that `[ "$x" != *pattern* ]` does NOT glob-match --
## `[` compares strings -- so the previous form here was always true.
##
## Both variables are wrapped in ':' before matching so that an entry only
## counts as present when it is a whole path element, not a prefix of one
## (e.g. /opt/local/lib must not match /opt/local/lib64).
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
