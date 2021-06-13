#!/bin/bash

export BINARY_TAG=x86_64-linux-gcc9-opt
if [ ! -z ${ATHENA_PREFIX} ]; then
  if [  "$LD_LIBRARY_PATH" != *"${ATHENA_PREFIX}/lib"* ]; then
    export LD_LIBRARY_PATH=$ATHENA_PREFIX/lib:$LD_LIBRARY_PATH
    export PATH=$ATHENA_PREFIX/bin:$PATH
  fi
fi
