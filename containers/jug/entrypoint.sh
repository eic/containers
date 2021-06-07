#!/usr/bin/env bash

source /etc/profile
## Force environment to be clean
source /etc/eic-env.sh

exec "$@"
