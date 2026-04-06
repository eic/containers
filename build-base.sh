#!/bin/bash
# Build the EIC base container image (debian_stable_base, cuda_devel, or cuda_runtime).
#
# This script is used both in CI (via .gitlab-ci.yml) and for local builds.
# CI mode is detected by the presence of the CI_REGISTRY environment variable.
#
# Usage (local):
#   bash build-base.sh [options]
#
# Usage (CI, called from .gitlab-ci.yml with matrix variables in env):
#   bash build-base.sh
#
# Options:
#   --image IMAGE       Image to build: debian_stable_base, cuda_devel, cuda_runtime
#                       (default: $BUILD_IMAGE or debian_stable_base)
#   --base-image IMAGE  Upstream base image (default: derived from --image)
#   --platform PLATFORM Build platform, e.g. linux/amd64, linux/arm64
#                       (default: $PLATFORM or linux/amd64)
#   --jobs N            Number of parallel Spack build jobs (default: $JOBS or 4)
#   --tag TAG           Local tag for the image (default: local; ignored in CI)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Defaults (may be overridden by env vars set from CI matrix or command-line flags)
BUILD_IMAGE="${BUILD_IMAGE:-debian_stable_base}"
BASE_IMAGE="${BASE_IMAGE:-}"
PLATFORM="${PLATFORM:-linux/amd64}"
JOBS="${JOBS:-4}"
LOCAL_TAG="${LOCAL_TAG:-local}"
## CUDA defaults (used when building cuda_devel or cuda_runtime)
CUDA_VERSION="${CUDA_VERSION:-12.5.1}"
CUDA_OS="${CUDA_OS:-ubuntu24.04}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)     BUILD_IMAGE="$2";   shift 2 ;;
    --base-image) BASE_IMAGE="$2";   shift 2 ;;
    --platform)  PLATFORM="$2";     shift 2 ;;
    --jobs)      JOBS="$2";         shift 2 ;;
    --tag)       LOCAL_TAG="$2";    shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

## Source version files
source "${SCRIPT_DIR}/spack.sh"
source "${SCRIPT_DIR}/spack-packages.sh"
source "${SCRIPT_DIR}/key4hep-spack.sh"
source "${SCRIPT_DIR}/eic-spack.sh"

## Derive BASE_IMAGE from BUILD_IMAGE if not provided
if [ -z "${BASE_IMAGE}" ]; then
  case "${BUILD_IMAGE}" in
    debian_stable_base) BASE_IMAGE="debian:trixie-slim" ;;
    cuda_devel)         BASE_IMAGE="nvidia/cuda:${CUDA_VERSION}-devel-${CUDA_OS}" ;;
    cuda_runtime)       BASE_IMAGE="nvidia/cuda:${CUDA_VERSION}-runtime-${CUDA_OS}" ;;
    *) echo "Unknown BUILD_IMAGE '${BUILD_IMAGE}'; please specify --base-image" >&2; exit 1 ;;
  esac
fi

## Resolve SHAs (network calls — skipped if version is already a SHA)
echo "Resolving git SHAs..."
SPACK_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" "${SPACK_ORGREPO}" "${SPACK_VERSION}")
SPACKPACKAGES_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" "${SPACKPACKAGES_ORGREPO}" "${SPACKPACKAGES_VERSION}")
KEY4HEPSPACK_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" "${KEY4HEPSPACK_ORGREPO}" "${KEY4HEPSPACK_VERSION}")
EICSPACK_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" "${EICSPACK_ORGREPO}" "${EICSPACK_VERSION}")

## Normalize arch string for cache tag names
ARCH=$(echo "${PLATFORM}" | sed 's|linux/||; s|/v[0-9]*$||')

## Build the docker buildx command as an array for safe quoting
build_cmd=(docker buildx build)
build_cmd+=(${BUILD_OPTIONS})  ## allow user to pass extra flags via BUILD_OPTIONS

## Output mode: push in CI, load locally
if [ -n "${CI_REGISTRY}" ]; then
  build_cmd+=(--push)
else
  build_cmd+=(--load)
fi

## Cache sources
if [ -n "${CI_REGISTRY}" ]; then
  build_cmd+=(--cache-from "type=registry,ref=${CI_REGISTRY}/${CI_PROJECT_PATH}/buildcache:${BUILD_IMAGE}-${CI_COMMIT_REF_SLUG}-${ARCH}")
fi
if [ -n "${GH_REGISTRY}" ] && [ -n "${GH_REGISTRY_USER}" ]; then
  build_cmd+=(--cache-from "type=registry,ref=${GH_REGISTRY}/${GH_REGISTRY_USER}/buildcache:${BUILD_IMAGE}-${CI_COMMIT_REF_SLUG:-master}-${ARCH}")
fi
if [ -n "${CI_REGISTRY}" ]; then
  build_cmd+=(--cache-from "type=registry,ref=${CI_REGISTRY}/${CI_PROJECT_PATH}/buildcache:${BUILD_IMAGE}-${CI_DEFAULT_BRANCH_SLUG}-${ARCH}")
fi
if [ -n "${GH_REGISTRY}" ] && [ -n "${GH_REGISTRY_USER}" ]; then
  build_cmd+=(--cache-from "type=registry,ref=${GH_REGISTRY}/${GH_REGISTRY_USER}/buildcache:${BUILD_IMAGE}-${CI_DEFAULT_BRANCH_SLUG:-master}-${ARCH}")
fi

## Cache destination (CI only)
if [ -n "${CI_REGISTRY}" ]; then
  build_cmd+=(--cache-to "type=registry,ref=${CI_REGISTRY}/${CI_PROJECT_PATH}/buildcache:${BUILD_IMAGE}-${CI_COMMIT_REF_SLUG}-${ARCH},mode=max")
fi

## Image tags
if [ -n "${CI_REGISTRY}" ]; then
  ## Always tag with INTERNAL_TAG in CI
  build_cmd+=(--tag "${CI_REGISTRY}/${CI_PROJECT_PATH}/${BUILD_IMAGE}:${INTERNAL_TAG}")
  ## Optionally tag with EXPORT_TAG on public registries
  if [ -n "${EXPORT_TAG}" ]; then
    [ -n "${CI_PUSH}" ] && build_cmd+=(--tag "${CI_REGISTRY}/${CI_PROJECT_PATH}/${BUILD_IMAGE}:${EXPORT_TAG}")
    [ -n "${DH_PUSH}" ] && build_cmd+=(--tag "${DH_REGISTRY}/${DH_REGISTRY_USER}/${BUILD_IMAGE}:${EXPORT_TAG}")
    [ -n "${GH_PUSH}" ] && build_cmd+=(--tag "${GH_REGISTRY}/${GH_REGISTRY_USER}/${BUILD_IMAGE}:${EXPORT_TAG}")
  fi
else
  build_cmd+=(--tag "${BUILD_IMAGE}:${LOCAL_TAG}")
fi

## Dockerfile and platform
build_cmd+=(--file containers/debian/Dockerfile)
build_cmd+=(--platform "${PLATFORM}")

## Build arguments
build_cmd+=(--build-arg "BASE_IMAGE=${BASE_IMAGE}")
build_cmd+=(--build-arg "BUILD_IMAGE=${BUILD_IMAGE}")
case "${BUILD_IMAGE}" in
  cuda*)
    build_cmd+=(--build-arg "NVIDIA_VISIBLE_DEVICES=all")
    build_cmd+=(--build-arg "NVIDIA_DRIVER_CAPABILITIES=all")
    ;;
esac
build_cmd+=(--build-arg "SPACK_ORGREPO=${SPACK_ORGREPO}")
build_cmd+=(--build-arg "SPACK_VERSION=${SPACK_VERSION}")
build_cmd+=(--build-arg "SPACK_SHA=${SPACK_SHA}")
build_cmd+=(--build-arg "SPACK_CHERRYPICKS=${SPACK_CHERRYPICKS}")
build_cmd+=(--build-arg "SPACK_CHERRYPICKS_FILES=${SPACK_CHERRYPICKS_FILES}")
build_cmd+=(--build-arg "SPACKPACKAGES_ORGREPO=${SPACKPACKAGES_ORGREPO}")
build_cmd+=(--build-arg "SPACKPACKAGES_VERSION=${SPACKPACKAGES_VERSION}")
build_cmd+=(--build-arg "SPACKPACKAGES_SHA=${SPACKPACKAGES_SHA}")
build_cmd+=(--build-arg "SPACKPACKAGES_CHERRYPICKS=${SPACKPACKAGES_CHERRYPICKS}")
build_cmd+=(--build-arg "SPACKPACKAGES_CHERRYPICKS_FILES=${SPACKPACKAGES_CHERRYPICKS_FILES}")
build_cmd+=(--build-arg "KEY4HEPSPACK_ORGREPO=${KEY4HEPSPACK_ORGREPO}")
build_cmd+=(--build-arg "KEY4HEPSPACK_VERSION=${KEY4HEPSPACK_VERSION}")
build_cmd+=(--build-arg "KEY4HEPSPACK_SHA=${KEY4HEPSPACK_SHA}")
build_cmd+=(--build-arg "EICSPACK_ORGREPO=${EICSPACK_ORGREPO}")
build_cmd+=(--build-arg "EICSPACK_VERSION=${EICSPACK_VERSION}")
build_cmd+=(--build-arg "EICSPACK_SHA=${EICSPACK_SHA}")
build_cmd+=(--build-arg "jobs=${JOBS}")
build_cmd+=(--build-arg "BUILDWEEK=${BUILDWEEK:-0}")

## Suppress provenance attestation (matches CI behaviour)
build_cmd+=(--provenance false)

## Build context
build_cmd+=(containers/debian)

## Execute
set -o xtrace
"${build_cmd[@]}" 2>&1 | tee build.log
