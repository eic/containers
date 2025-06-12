#!/bin/bash

# This script auto-loads epic-main configuration iff:
# - no $DETECTOR_PATH or $DETECTOR_CONFIG is set
# - /opt/detector/epic-main/bin/thisepic.sh exists

thisepic=/opt/detector/epic-main/bin/thisepic.sh
if test -z "$DETECTOR_PATH" -a -z "$DETECTOR_CONFIG" ; then
  if test -f $thisepic ; then
    source $thisepic
  fi
fi
