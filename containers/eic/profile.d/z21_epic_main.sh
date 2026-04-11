#!/bin/bash
# This script auto-loads epic-main configuration iff:
# - no $DETECTOR_PATH or $DETECTOR_CONFIG is set
# - /etc/jug_info contains a line with jug_.*
# - /etc/jug_info contains version info: 25.08.0-stable-*
# - /opt/detector/epic-${version}/bin/thisepic.sh exists
file=/etc/jug_info
if test -z "$DETECTOR_PATH" -a -z "$DETECTOR_CONFIG" ; then
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
      # Workaround for 26.04.0. After https://github.com/eic/epic/pull/1072 lands we can switch back to
      # . "$thisepic"
      eval "$(bash -c '. '"$thisepic"'; echo export DETECTOR=\"$DETECTOR\"; echo export DETECTOR_PATH=\"$DETECTOR_PATH\"; echo export DETECTOR_CONFIG=\"$DETECTOR_CONFIG\"; echo export DETECTOR_VERSION=\"$DETECTOR_VERSION\"')"
    fi
  fi
fi
