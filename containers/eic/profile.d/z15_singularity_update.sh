#!/bin/bash

## Warn users running singularity/apptainer when their outer eic-shell script is outdated.
## Users can upgrade by running `eic-shell --upgrade` outside the container.

# Only run for interactive shells
case "$-" in
  *i*) ;;
  *) return 0 ;;
esac

# Only run when inside singularity/apptainer
if [ -z "${SINGULARITY_CONTAINER:-}" ] && [ -z "${APPTAINER_CONTAINER:-}" ]; then
  return 0
fi

# Require EIC_SHELL_PREFIX to be set; otherwise we cannot locate the outer eic-shell
if [ -z "${EIC_SHELL_PREFIX:-}" ]; then
  return 0
fi

# Check if the outer eic-shell script is accessible
_outer_eic_shell="${EIC_SHELL_PREFIX}/../eic-shell"
if [ ! -f "$_outer_eic_shell" ]; then
  unset _outer_eic_shell
  return 0
fi

# Only warn if we have write access (meaning user can upgrade)
if [ ! -w "$_outer_eic_shell" ]; then
  unset _outer_eic_shell
  return 0
fi

# Warn if the outer eic-shell script is older than 6 months (~180 days)
if find "$_outer_eic_shell" -mtime +180 -print -quit 2>/dev/null | grep -q .; then
  echo ""
  echo "WARNING: Your eic-shell script appears to be more than 6 months old."
  echo "         Consider upgrading by running outside the container:"
  echo "           eic-shell --upgrade"
  echo ""
fi
unset _outer_eic_shell
