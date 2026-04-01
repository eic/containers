#!/bin/bash

# Create function for first invocation of spack
# that loads environment to avoid slow loads
# when sourcing environment by default
spack() {
    unset -f spack
    source "${SPACK_ROOT}/share/spack/setup-env.sh"
    spack "$@"
}
