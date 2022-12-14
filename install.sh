#!/bin/bash

# Pass the buck
curl -L https://github.com/eic/eic-shell/raw/main/install.sh | exec bash -s -- $*
