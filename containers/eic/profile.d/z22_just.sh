#!/bin/bash

if [ -n "${BASH_VERSION:-}" ]; then
  case $- in
    *i*)
      if command -v just >/dev/null 2>&1; then
        eval "$(just --completions bash)"
      fi
      ;;
  esac
fi
