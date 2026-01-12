#!/bin/bash

# Create alias for first invocation of spack
# that loads environment to avoid slow loads
# wben sourcing environment by default
alias spack='unalias spack && source ${SPACK_ROOT}/share/spack/setup-env.sh && spack'
