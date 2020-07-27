#!/usr/bin/env bash

## Extract a list of the variable definitions needed
## for this environment from the builder image, and 
## then configure the release Dockerfile to set these
## variables

mkdir -p config

cp /etc/profile.d/z10_spack_environment.sh config/spack-env.sh

## ensure we also have /lib/x86_64-linux-gnu in our library path
## as it contains important ubuntu system libraries
sed -i "s?LD_LIBRARY_PATH=?&/lib/x86_64-linux-gnu:?" config/spack-env.sh

## Spack sets the man-path, which stops bash from using the default man-path
## We can fix this by appending a trailing colon to MANPATH
sed -i '/MANPATH/ s/;$/:;/' config/spack-env.sh

## Extract the desired environment variables as defined by spack
grep export config/spack-env.sh | \
  sed 's/export /    /' | \
  sed 's/;$/ \\/' > config/eic-env.sh

## create our release Dockerfile
sed '/^@ENV@/r config/eic-env.sh' containers/release/Dockerfile.in | \
  sed '/^@ENV@/d' > config/Dockerfile
