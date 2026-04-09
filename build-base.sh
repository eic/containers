#!/bin/bash
# Build the EIC base container image (debian_stable_base, cuda_devel, or cuda_runtime).
#
# This script is used in GitLab CI, GitHub Actions, and for local builds.
# CI mode is detected via CI_REGISTRY (GitLab) or GITHUB_ACTIONS=true (GitHub Actions).
#
# Usage (local):
#   bash build-base.sh [options]
#
# Usage (CI, called from .gitlab-ci.yml or build-push.yml with matrix variables in env):
#   bash build-base.sh
#
# Options:
#   --image IMAGE       Image to build: debian_stable_base, cuda_devel, cuda_runtime
#                       (default: $BUILD_IMAGE or debian_stable_base)
#   --base-image IMAGE  Upstream base image (default: derived from --image)
#   --platform PLATFORM Build platform, e.g. linux/amd64, linux/arm64
#                       (default: $PLATFORM or linux/amd64)
#   --jobs N            Number of parallel Spack build jobs (default: $JOBS or $(nproc))
#   --tag TAG           Local tag for the image (default: local; ignored in CI)
#
# GitHub Actions mode (GITHUB_ACTIONS=true):
#   Set GH_REGISTRY, GH_REGISTRY_USER, JOBS.  The script reads GITHUB_REF_POINT_SLUG
#   and GITHUB_BASE_REF_SLUG (from rlespinasse/github-slug-action) for cache keys, and
#   writes the image digest to METADATA_FILE (default: /tmp/build-metadata.json).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Defaults (may be overridden by env vars set from CI matrix or command-line flags)
BUILD_IMAGE="${BUILD_IMAGE:-debian_stable_base}"
BASE_IMAGE="${BASE_IMAGE:-}"
PLATFORM="${PLATFORM:-linux/amd64}"
JOBS="${JOBS:-$(nproc)}"
LOCAL_TAG="${LOCAL_TAG:-local}"
METADATA_FILE="${METADATA_FILE:-/tmp/build-metadata.json}"
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

## Detect CI mode and normalise environment variables
if [ -n "${CI_REGISTRY}" ]; then
  ## GitLab CI — all CI_* variables are already set by the runner
  CI_MODE="gitlab"
elif [ "${GITHUB_ACTIONS}" = "true" ]; then
  ## GitHub Actions — map GitHub variables to the names used below
  ## GITHUB_REF_POINT_SLUG and GITHUB_BASE_REF_SLUG are set by rlespinasse/github-slug-action
  CI_MODE="github"
  CI_REGISTRY="${GH_REGISTRY}"
  CI_PROJECT_PATH="${GH_REGISTRY_USER}"
  CI_COMMIT_REF_SLUG="${GITHUB_REF_POINT_SLUG:-master}"
  CI_DEFAULT_BRANCH_SLUG="${GITHUB_BASE_REF_SLUG:-master}"
  INTERNAL_TAG="${INTERNAL_TAG:-pipeline-${GITHUB_RUN_ID}}"
else
  CI_MODE="local"
fi

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
# shellcheck disable=SC2206  # word splitting is intentional: BUILD_OPTIONS is a space-separated list
build_cmd+=(${BUILD_OPTIONS})

## Derive shared registry prefix (used for image push, caching, and DOCKER_REGISTRY build-arg)
CI_REGISTRY_PREFIX="${CI_REGISTRY}/${CI_PROJECT_PATH}"
IMAGE_REPO="${CI_REGISTRY_PREFIX}/${BUILD_IMAGE}"

## Output mode: push-by-digest in all CI modes; load locally
if [ "${CI_MODE}" != "local" ]; then
  ## Push by digest; CI wrapper creates final tags via imagetools create
  build_cmd+=(--output "type=image,name=${IMAGE_REPO},push-by-digest=true,name-canonical=true,push=true")
  build_cmd+=(--metadata-file "${METADATA_FILE}")
else
  build_cmd+=(--load)
fi

## Cache sources: CI registry (if in CI) plus public ghcr.io/eic (GitLab and local modes)
BUILDCACHE_REPOS=()
[ "${CI_MODE}" != "local" ] && BUILDCACHE_REPOS+=("${CI_REGISTRY_PREFIX}")
[ "${CI_MODE}" != "github" ] && BUILDCACHE_REPOS+=("ghcr.io/eic")
for REPO in "${BUILDCACHE_REPOS[@]}"; do
  build_cmd+=(--cache-from "type=registry,ref=${REPO}/buildcache:${BUILD_IMAGE}-${CI_COMMIT_REF_SLUG:-master}-${ARCH}")
  build_cmd+=(--cache-from "type=registry,ref=${REPO}/buildcache:${BUILD_IMAGE}-${CI_DEFAULT_BRANCH_SLUG:-master}-${ARCH}")
done

## Cache destination (CI only)
if [ "${CI_MODE}" != "local" ]; then
  build_cmd+=(--cache-to "type=registry,ref=${CI_REGISTRY_PREFIX}/buildcache:${BUILD_IMAGE}-${CI_COMMIT_REF_SLUG:-master}-${ARCH},mode=max")
fi

## Image tag (local only; CI creates tags via imagetools create after build)
if [ "${CI_MODE}" = "local" ]; then
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
set -o xtrace -o pipefail
"${build_cmd[@]}" 2>&1 | tee build.log

## Create image tags from digest (GitLab CI only; GitHub Actions manifest jobs handle tagging)
if [ "${CI_MODE}" = "gitlab" ]; then
  DIGEST=$(jq -r '."containerimage.digest"' "${METADATA_FILE}")
  docker buildx imagetools create --tag "${IMAGE_REPO}:${INTERNAL_TAG}" "${IMAGE_REPO}@${DIGEST}"
  if [ -n "${EXPORT_TAG}" ]; then
    [ -n "${CI_PUSH}" ] && docker buildx imagetools create --tag "${IMAGE_REPO}:${EXPORT_TAG}" "${IMAGE_REPO}@${DIGEST}"
    [ -n "${DH_PUSH}" ] && docker buildx imagetools create --tag "${DH_REGISTRY}/${DH_REGISTRY_USER}/${BUILD_IMAGE}:${EXPORT_TAG}" "${IMAGE_REPO}@${DIGEST}"
    [ -n "${GH_PUSH}" ] && docker buildx imagetools create --tag "${GH_REGISTRY}/${GH_REGISTRY_USER}/${BUILD_IMAGE}:${EXPORT_TAG}" "${IMAGE_REPO}@${DIGEST}"
  fi
fi
