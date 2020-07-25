#!/usr/bin/env bash

## Extract a list of the variable definitions needed
## for this environment from the builder image, and 
## then configure the release Dockerfile to set these
## variables

mkdir -p config

## Extract the desired environment variables as defined by spack
grep export /etc/profile.d/z10_spack_environment.sh | \
  sed 's/export /    /' | \
  sed 's/;$/ \\/' > config/eic-env.sh

## ensure we also have /lib/x86_64-linux-gnu in our library path
## as it contains important ubuntu system libraries
sed -i "s?LD_LIBRARY_PATH=?&/lib/x86_64-linux-gnu:?" config/eic-env.sh

## create our release Dockerfile
sed '/^@ENV@/r config/eic-env.sh' containers/release/Dockerfile.in | \
  sed '/^@ENV@/d' > config/Dockerfile
