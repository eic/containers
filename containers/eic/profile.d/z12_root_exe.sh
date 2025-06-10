#!/bin/bash

# The command `root` is only installed when ROOT has X11 support,
# so we alias `root` to `root.exe` when no X11 support is included.
if ! which root > /dev/null && which root.exe > /dev/null ; then
  alias root=root.exe
fi
