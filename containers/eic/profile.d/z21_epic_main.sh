#!/bin/bash

# This script auto-loads epic-main configuration iff:
# - no $DETECTOR_PATH or $DETECTOR_CONFIG is set
# - /etc/jug_info contains a line with eic_container
# - /etc/jug_info contains eic_container: 25.08.0-stable-*
# - /opt/detector/epic-${version}/bin/thisepic.sh exists

file=/etc/jug_info
if test -z "$DETECTOR_PATH" -a -z "$DETECTOR_CONFIG" ; then
  if test -f $file ; then
    version="main"

    eic_container_version=$(sed -nr 's/.*eic_container: (.*)/\1/p' $file)
    if test -n "$eic_container_version" ; then
      if [[ $eic_container_version =~ ([0-9]{2}\.[0-9]{2}\.[0-9])-stable-.* ]] ; then
        version=${BASH_REMATCH[1]}
      fi
    fi

    thisepic=/opt/detector/epic-${version}/bin/thisepic.sh
    if test -f $thisepic ; then
      source $thisepic
    fi
  fi
fi
