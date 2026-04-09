#!/bin/bash
# Build an EIC container image (eic_ci, eic_xl, eic_cuda, etc.).
#
# This script is used in GitLab CI, GitHub Actions, and for local builds.
# CI mode is detected via CI_REGISTRY (GitLab) or GITHUB_ACTIONS=true (GitHub Actions).
#
# Usage (local):
#   bash build-eic.sh [options]
#
# Usage (CI, called from .gitlab-ci.yml or build-push.yml with matrix variables in env):
#   bash build-eic.sh
#
# Options:
#   --env ENV           Environment: ci, xl, cuda, dbg, jl, prod, cvmfs, tf, ...
#                       (default: $ENV or xl)
#   --build-type TYPE   Build type: default or nightly (default: $BUILD_TYPE or default)
#   --builder-image IMG Builder base image name (default: $BUILDER_IMAGE or debian_stable_base)
#   --runtime-image IMG Runtime base image name (default: $RUNTIME_IMAGE or debian_stable_base)
#   --target STAGE      Docker build target stage (default: $BUILD_TARGET or final)
#   --platform PLATFORM Build platform, e.g. linux/amd64 (default: $PLATFORM or linux/amd64)
#   --jobs N            Number of parallel Spack build jobs (default: $JOBS or 4)
#   --base-tag TAG      Tag of the base image to use (default: local in local mode, $INTERNAL_TAG in CI)
#   --tag TAG           Local tag for the output image (default: local; ignored in CI)
#
# GitHub Actions mode (GITHUB_ACTIONS=true):
#   Set GH_REGISTRY, GH_REGISTRY_USER, JOBS.  The script reads GITHUB_REF_POINT_SLUG
#   and GITHUB_BASE_REF_SLUG (from rlespinasse/github-slug-action) for cache keys, and
#   writes the image digest to METADATA_FILE (default: /tmp/build-metadata.json).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Defaults (may be overridden by env vars set from CI matrix or command-line flags)
BUILD_IMAGE="${BUILD_IMAGE:-eic_}"
ENV="${ENV:-xl}"
BUILD_TYPE="${BUILD_TYPE:-default}"
BUILDER_IMAGE="${BUILDER_IMAGE:-debian_stable_base}"
RUNTIME_IMAGE="${RUNTIME_IMAGE:-debian_stable_base}"
BUILD_TARGET="${BUILD_TARGET:-final}"
PLATFORM="${PLATFORM:-linux/amd64}"
JOBS="${JOBS:-$(nproc)}"
LOCAL_TAG="${LOCAL_TAG:-local}"
LOCAL_BASE_TAG="${LOCAL_BASE_TAG:-local}"
METADATA_FILE="${METADATA_FILE:-/tmp/build-metadata.json}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)           ENV="$2";           shift 2 ;;
    --build-type)    BUILD_TYPE="$2";    shift 2 ;;
    --builder-image) BUILDER_IMAGE="$2"; shift 2 ;;
    --runtime-image) RUNTIME_IMAGE="$2"; shift 2 ;;
    --target)        BUILD_TARGET="$2";  shift 2 ;;
    --platform)      PLATFORM="$2";     shift 2 ;;
    --jobs)          JOBS="$2";         shift 2 ;;
    --base-tag)      LOCAL_BASE_TAG="$2"; shift 2 ;;
    --tag)           LOCAL_TAG="$2";    shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

## Source version files (only spack-packages version is needed for mirrors.yaml)
source "${SCRIPT_DIR}/spack-packages.sh"

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
  CI_COMMIT_SHA="${GITHUB_SHA:-}"
  INTERNAL_TAG="${INTERNAL_TAG:-pipeline-${GITHUB_RUN_ID}}"
else
  CI_MODE="local"
fi

## Generate mirrors.yaml from template or create a public-only version.
## Uses sed rather than envsubst to avoid a runtime dependency on gettext.
if [ "${CI_MODE}" != "local" ]; then
  ## CI mode: expand CI_REGISTRY/CI_PROJECT_PATH variables in the template
  sed -e "s|\${CI_REGISTRY}|${CI_REGISTRY}|g" \
      -e "s|\${CI_PROJECT_PATH}|${CI_PROJECT_PATH}|g" \
      -e "s|\${SPACKPACKAGES_VERSION}|${SPACKPACKAGES_VERSION}|g" \
      "${SCRIPT_DIR}/mirrors.yaml.in" > "${SCRIPT_DIR}/mirrors.yaml"
else
  ## Local mode: public-only mirrors (no credentials required)
  cat > "${SCRIPT_DIR}/mirrors.yaml" <<EOF
mirrors:
  ghcr:
    url: oci://ghcr.io/eic/spack-${SPACKPACKAGES_VERSION}
    signed: false
  spack:
    url: https://binaries.spack.io/v1.0
    signed: false
EOF
fi

## Resolve SHAs (network calls — skipped if version is already a SHA)
echo "Resolving git SHAs..."
BENCHMARK_COM_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" https://eicweb.phy.anl.gov/EIC/benchmarks/common_bench.git master)
BENCHMARK_DET_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" https://eicweb.phy.anl.gov/EIC/benchmarks/detector_benchmarks.git master)
BENCHMARK_REC_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" https://eicweb.phy.anl.gov/EIC/benchmarks/reconstruction_benchmarks.git master)
BENCHMARK_PHY_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" https://eicweb.phy.anl.gov/EIC/benchmarks/physics_benchmarks.git master)
CAMPAIGNS_HEPMC3_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" eic/simulation_campaign_hepmc3 main)
CAMPAIGNS_CONDOR_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" eic/job_submission_condor main)
CAMPAIGNS_SLURM_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" eic/job_submission_slurm main)

## Resolve optional version overrides (nightly always resolves; default only if version set)
if [ "${BUILD_TYPE}" = "nightly" ]; then
  EDM4EIC_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" eic/EDM4eic "${EDM4EIC_VERSION:-main}")
  EICRECON_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" eic/EICrecon "${EICRECON_VERSION:-main}")
  EPIC_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" eic/epic "${EPIC_VERSION:-main}")
  JUGGLER_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" eic/juggler "${JUGGLER_VERSION:-main}")
else
  ## default build: only resolve if version is explicitly provided
  [ -n "${EDM4EIC_VERSION}" ]  && EDM4EIC_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" eic/EDM4eic  "${EDM4EIC_VERSION}")
  [ -n "${EICRECON_VERSION}" ] && EICRECON_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref" eic/EICrecon "${EICRECON_VERSION}")
  [ -n "${EPIC_VERSION}" ]     && EPIC_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref"     eic/epic     "${EPIC_VERSION}")
  [ -n "${JUGGLER_VERSION}" ]  && JUGGLER_SHA=$(sh "${SCRIPT_DIR}/.ci/resolve_git_ref"  eic/juggler  "${JUGGLER_VERSION}")
fi

## Compute per-ENV duplicate allowlist
case "${ENV}" in
  xl|tf)
    SPACK_DUPLICATE_ALLOWLIST="epic|llvm|py-setuptools|py-urllib3|py-dask|py-dask-awkward|py-dask-histogram|py-distributed|py-requests" ;;
  *)
    SPACK_DUPLICATE_ALLOWLIST="epic|llvm|py-setuptools|py-urllib3" ;;
esac

## Normalize arch string for cache tag names
ARCH=$(echo "${PLATFORM}" | sed 's|linux/||; s|/v[0-9]*$||')

## Build the docker buildx command as an array for safe quoting
build_cmd=(docker buildx build)
# shellcheck disable=SC2206  # word splitting is intentional: BUILD_OPTIONS is a space-separated list
build_cmd+=(${BUILD_OPTIONS})

## Derive shared registry prefix (used for image push, caching, and DOCKER_REGISTRY build-arg)
CI_REGISTRY_PREFIX="${CI_REGISTRY}/${CI_PROJECT_PATH}"
IMAGE_REPO="${CI_REGISTRY_PREFIX}/${BUILD_IMAGE}${ENV}"

## Output mode: push-by-digest in all CI modes; load locally
if [ "${CI_MODE}" != "local" ]; then
  ## Push by digest; CI wrapper creates final tags via imagetools create
  build_cmd+=(--output "type=image,name=${IMAGE_REPO},push-by-digest=true,name-canonical=true,push=true")
  build_cmd+=(--metadata-file "${METADATA_FILE}")
else
  build_cmd+=(--load)
fi

## Cache sources: CI registry (if in CI) plus public ghcr.io/eic (GitLab and local modes)
CACHE_KEY="${BUILD_IMAGE}${ENV}-${BUILD_TYPE}"
BUILDCACHE_REPOS=()
[ "${CI_MODE}" != "local" ] && BUILDCACHE_REPOS+=("${CI_REGISTRY_PREFIX}")
[ "${CI_MODE}" != "github" ] && BUILDCACHE_REPOS+=("ghcr.io/eic")
for REPO in "${BUILDCACHE_REPOS[@]}"; do
  build_cmd+=(--cache-from "type=registry,ref=${REPO}/buildcache:${CACHE_KEY}-${CI_COMMIT_REF_SLUG:-master}-${ARCH}")
  build_cmd+=(--cache-from "type=registry,ref=${REPO}/buildcache:${CACHE_KEY}-${CI_DEFAULT_BRANCH_SLUG:-master}-${ARCH}")
done

## Cache destination (CI only)
if [ "${CI_MODE}" != "local" ]; then
  build_cmd+=(--cache-to "type=registry,ref=${CI_REGISTRY_PREFIX}/buildcache:${CACHE_KEY}-${CI_COMMIT_REF_SLUG:-master}-${ARCH},mode=max")
fi

## Image tag (local only; CI creates tags via imagetools create after build)
if [ "${CI_MODE}" = "local" ]; then
  build_cmd+=(--tag "${BUILD_IMAGE}${ENV}:${LOCAL_TAG}")
fi

## Dockerfile, target stage, and platform
build_cmd+=(--file containers/eic/Dockerfile)
[ -n "${BUILD_TARGET}" ] && build_cmd+=(--target "${BUILD_TARGET}")
build_cmd+=(--platform "${PLATFORM}")

## Build arguments
build_cmd+=(--build-arg "BENCHMARK_COM_SHA=${BENCHMARK_COM_SHA}")
build_cmd+=(--build-arg "BENCHMARK_DET_SHA=${BENCHMARK_DET_SHA}")
build_cmd+=(--build-arg "BENCHMARK_REC_SHA=${BENCHMARK_REC_SHA}")
build_cmd+=(--build-arg "BENCHMARK_PHY_SHA=${BENCHMARK_PHY_SHA}")
build_cmd+=(--build-arg "CAMPAIGNS_HEPMC3_SHA=${CAMPAIGNS_HEPMC3_SHA}")
build_cmd+=(--build-arg "CAMPAIGNS_CONDOR_SHA=${CAMPAIGNS_CONDOR_SHA}")
build_cmd+=(--build-arg "CAMPAIGNS_SLURM_SHA=${CAMPAIGNS_SLURM_SHA}")

if [ "${CI_MODE}" != "local" ]; then
  build_cmd+=(--build-arg "DOCKER_REGISTRY=${CI_REGISTRY_PREFIX}/")
  build_cmd+=(--build-arg "INTERNAL_TAG=${INTERNAL_TAG}")
  build_cmd+=(--build-arg "CI_COMMIT_SHA=${CI_COMMIT_SHA}")
else
  build_cmd+=(--build-arg "DOCKER_REGISTRY=ghcr.io/eic/")
  build_cmd+=(--build-arg "INTERNAL_TAG=${LOCAL_BASE_TAG}")
fi
## EIC_CONTAINER_VERSION format is intentionally different per CI system
if [ "${CI_MODE}" = "gitlab" ]; then
  build_cmd+=(--build-arg "EIC_CONTAINER_VERSION=${EXPORT_TAG}-${BUILD_TYPE}-$(git rev-parse HEAD)")
elif [ "${CI_MODE}" = "github" ]; then
  build_cmd+=(--build-arg "EIC_CONTAINER_VERSION=github-${BUILD_TYPE}-${CI_COMMIT_SHA:-$(git rev-parse HEAD 2>/dev/null || echo unknown)}")
else
  build_cmd+=(--build-arg "EIC_CONTAINER_VERSION=local-${BUILD_TYPE}-$(git rev-parse HEAD 2>/dev/null || echo unknown)")
fi

build_cmd+=(--build-arg "BUILDER_IMAGE=${BUILDER_IMAGE}")
build_cmd+=(--build-arg "RUNTIME_IMAGE=${RUNTIME_IMAGE}")
build_cmd+=(--build-arg "ENV=${ENV}")
build_cmd+=(--build-arg "SPACK_DUPLICATE_ALLOWLIST=${SPACK_DUPLICATE_ALLOWLIST}")
build_cmd+=(--build-arg "jobs=${JOBS}")

## Optional version overrides
[ -n "${EDM4EIC_SHA}" ]  && build_cmd+=(--build-arg "EDM4EIC_SHA=${EDM4EIC_SHA}")
[ -n "${EICRECON_SHA}" ] && build_cmd+=(--build-arg "EICRECON_SHA=${EICRECON_SHA}")
[ -n "${EPIC_SHA}" ]     && build_cmd+=(--build-arg "EPIC_SHA=${EPIC_SHA}")
[ -n "${JUGGLER_SHA}" ]  && build_cmd+=(--build-arg "JUGGLER_SHA=${JUGGLER_SHA}")

## Additional build contexts
build_cmd+=(--build-context "spack-environment=spack-environment")

## Secrets
build_cmd+=(--secret "id=mirrors,src=${SCRIPT_DIR}/mirrors.yaml")
if [ "${CI_MODE}" != "local" ]; then
  build_cmd+=(--secret "type=env,id=CI_REGISTRY_USER,env=CI_REGISTRY_USER")
  build_cmd+=(--secret "type=env,id=CI_REGISTRY_PASSWORD,env=CI_REGISTRY_PASSWORD")
  build_cmd+=(--secret "type=env,id=GITHUB_REGISTRY_USER,env=GITHUB_REGISTRY_USER")
  build_cmd+=(--secret "type=env,id=GITHUB_REGISTRY_TOKEN,env=GITHUB_REGISTRY_TOKEN")
fi

## Suppress provenance attestation (matches CI behaviour)
build_cmd+=(--provenance false)

## Build context
build_cmd+=(containers/eic)

## Execute
set -o xtrace -o pipefail
"${build_cmd[@]}" 2>&1 | tee build.log

## Create image tags from digest (GitLab CI only; GitHub Actions manifest jobs handle tagging)
if [ "${CI_MODE}" = "gitlab" ]; then
  DIGEST=$(jq -r '."containerimage.digest"' "${METADATA_FILE}")
  docker buildx imagetools create --tag "${IMAGE_REPO}:${INTERNAL_TAG}-${BUILD_TYPE}" "${IMAGE_REPO}@${DIGEST}"
  if [ -n "${EXPORT_TAG}" ]; then
    if [ "${BUILD_TYPE}" = "default" ]; then
      [ -n "${CI_PUSH}" ] && docker buildx imagetools create --tag "${IMAGE_REPO}:${EXPORT_TAG}" "${IMAGE_REPO}@${DIGEST}"
      [ -n "${DH_PUSH}" ] && docker buildx imagetools create --tag "${DH_REGISTRY}/${DH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${EXPORT_TAG}" "${IMAGE_REPO}@${DIGEST}"
      [ -n "${GH_PUSH}" ] && docker buildx imagetools create --tag "${GH_REGISTRY}/${GH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${EXPORT_TAG}" "${IMAGE_REPO}@${DIGEST}"
    else
      [ -n "${CI_PUSH}" ] && docker buildx imagetools create --tag "${IMAGE_REPO}:${EXPORT_TAG}-${BUILD_TYPE}" "${IMAGE_REPO}@${DIGEST}"
      [ -n "${DH_PUSH}" ] && docker buildx imagetools create --tag "${DH_REGISTRY}/${DH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${EXPORT_TAG}-${BUILD_TYPE}" "${IMAGE_REPO}@${DIGEST}"
      [ -n "${GH_PUSH}" ] && docker buildx imagetools create --tag "${GH_REGISTRY}/${GH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${EXPORT_TAG}-${BUILD_TYPE}" "${IMAGE_REPO}@${DIGEST}"
    fi
  fi
  if [ "${BUILD_TYPE}" = "nightly" ] && [ -n "${NIGHTLY}" ]; then
    [ -n "${CI_PUSH}" ] && docker buildx imagetools create --tag "${IMAGE_REPO}:${NIGHTLY_TAG}" "${IMAGE_REPO}@${DIGEST}"
    [ -n "${DH_PUSH}" ] && docker buildx imagetools create --tag "${DH_REGISTRY}/${DH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${NIGHTLY_TAG}" "${IMAGE_REPO}@${DIGEST}"
    [ -n "${GH_PUSH}" ] && docker buildx imagetools create --tag "${GH_REGISTRY}/${GH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${NIGHTLY_TAG}" "${IMAGE_REPO}@${DIGEST}"
  fi
fi
