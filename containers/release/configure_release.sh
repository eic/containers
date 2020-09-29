#!/usr/bin/env bash

## Extract a list of the variable definitions needed
## for this environment from the builder image, and 
## then configure the release Dockerfile to set these
## variables

mkdir -p config

cp /etc/profile.d/z10_spack_environment.sh config/spack-env.sh

export TAG=$1

## Spack sets the man-path, which stops bash from using the default man-path
## We can fix this by appending a trailing colon to MANPATH
sed -i '/MANPATH/ s/;$/:;/' config/spack-env.sh

## Extract the desired environment variables as defined by spack
grep export config/spack-env.sh | \
  sed 's/export /    /' | \
  sed 's/;$/ \\/' > config/eic-env.sh

## create our release Dockerfile
sed '/^@ENV@/r config/eic-env.sh' containers/release/Dockerfile.in | \
  sed '/^@ENV@/d' | \
  sed "s/@TAG@/$TAG/" > config/Dockerfile
