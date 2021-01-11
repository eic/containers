#!/bin/bash

## Update the spack buildcache with the contents of this image
## Note: this needs to be run manually from the CI machine with
##       all relevant directories mounted into the image.

## info of spack installation on CI machine
GLOBAL_SPACK_ROOT=/lab/opt/spack
LOCAL_SPACK_ROOT=/opt/spack
SPACK_MIRROR=$GLOBAL_SPACK_ROOT/var/mirror

## two use cases:
## 1. arguments supplied --> update the packages in the arguments
## 2. no arguments supplied --> update all packages

function print_the_help() {
  echo "USAGE: $0 [-h] [packages ...]"
  echo ""
  echo "        Update the spack buildcache with contents of this image."
  echo "        If no packages are supplied on the command line, create"
  echo "        cache for *all* packages in this image"
  exit
}


positional=("$@")
while [ $# -gt 0 ]; do
  key="$1"
  case $key in
    *-h|--help) 
      print_the_help
      exit 0
      shift
      ;;
    *)    # unknown option, do nothing
      shift
      ;;
  esac
done
set -- "${positional[@]}"

## setup GPG to sign packages
rm -rf $LOCAL_SPACK_ROOT/opt/spack/gpg
cp -r $GLOBAL_SPACK_ROOT/opt/spack/gpg $LOCAL_SPACK_ROOT/opt/spack/gpg

## case 1: no argument --> export all
if [ $# -eq 0 ]; then
  ## list all available packages
  spack find > tmp.manifest.txt

  ## trim off the first line, trim off the version info 
  ## and replace newlines with spaces
  tail -n +2 tmp.manifest.txt | sed "s/@.+//" | tr '\n' ' ' > tmp.packages.txt
  rm tmp.manifest.txt
## case 2: update requested packages only
else
  echo $@ > tmp.packages.txt
fi

## now generate the buildcache (this will take a while)
cat tmp.packages.txt | xargs spack buildcache create -a -f -d $SPACK_MIRROR
spack buildcache update-index -d /lab/opt/spack/var/mirror
rm tmp.packages.txt

## That's all!
