# shellcheck shell=bash
# shellcheck disable=SC2034  # Variables are used by scripts that source this file
## CUDA toolkit version and OS of the nvidia/cuda base images, i.e.
## nvidia/cuda:${CUDA_VERSION}-{devel,runtime}-${CUDA_OS}
##
## Single source of truth: scripts/build-base.sh sources this file to derive
## BASE_IMAGE for cuda_devel and cuda_runtime, in GitHub Actions, GitLab CI and
## local builds alike. Values already set in the environment take precedence.
CUDA_VERSION="${CUDA_VERSION:-12.8.2}"
CUDA_OS="${CUDA_OS:-ubuntu24.04}"
