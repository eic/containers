#!/bin/bash
# This script auto-loads epic-main configuration iff:
# - no $DETECTOR_PATH or $DETECTOR_CONFIG is set
# - /etc/jug_info contains a line with jug_.*
# - /etc/jug_info contains version info: 25.08.0-stable-*
# - /opt/detector/epic-${version}/bin/thisepic.sh exists
# If $DETECTOR_PATH is set, the installed geometry with that path is loaded again
# (a00_cleanup.sh resets LD_LIBRARY_PATH each time the profile scripts run).
file=/etc/jug_info
# A wrapper that blocks propagation of $@, $1, etc.
_sourceWithoutArgs() {
    local fileToSource="$1"
    shift
    . "$fileToSource"
}
if test -n "$DETECTOR_PATH" ; then
  thisepic=$(grep -lxF "export DETECTOR_PATH=$(readlink -f "$DETECTOR_PATH")" /opt/detector/epic-*/bin/thisepic.sh 2>/dev/null | head -n 1)
  if test -n "$thisepic" ; then
    config="$DETECTOR_CONFIG"
    # shellcheck source=/dev/null  # path depends on the selected geometry
    _sourceWithoutArgs "$thisepic"
    export DETECTOR_CONFIG="${config:-$DETECTOR_CONFIG}"
  fi
elif test -z "$DETECTOR_CONFIG" ; then
  if test -f "$file" ; then
    version="main"
    eic_container_version=$(sed -n 's/.*jug_.*: \(.*\)/\1/p' "$file")
    if test -n "$eic_container_version" ; then
      # Extract version using sed with basic regex (POSIX)
      extracted_version=$(echo "$eic_container_version" | sed -n 's/^\([0-9]\{2\}\.[0-9]\{2\}\.[0-9]\)-stable-.*/\1/p')
      if test -n "$extracted_version" ; then
        version="$extracted_version"
      fi
    fi
    thisepic=/opt/detector/epic-${version}/bin/thisepic.sh
    if test -f "$thisepic" ; then
      # shellcheck source=/dev/null  # path depends on the detected version
      _sourceWithoutArgs "$thisepic"
    fi
  fi
fi
