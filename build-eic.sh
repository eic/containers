#!/bin/bash
# Build an EIC container image (eic_ci, eic_xl, eic_cuda, etc.).
#
# This script is used both in CI (via .gitlab-ci.yml) and for local builds.
# CI mode is detected by the presence of the CI_REGISTRY environment variable.
#
# Usage (local):
#   bash build-eic.sh [options]
#
# Usage (CI, called from .gitlab-ci.yml with matrix variables in env):
#   bash build-eic.sh
#
# Options:
#   --env ENV           Environment: ci, xl, cuda, dbg, jl, prod, cvmfs, tf, ...
#                       (default: $ENV or xl)
#   --build-type TYPE   Build type: default or nightly (default: $BUILD_TYPE or default)
#   --builder-image IMG Builder base image name (default: $BUILDER_IMAGE or debian_stable_base)
#   --runtime-image IMG Runtime base image name (default: $RUNTIME_IMAGE or debian_stable_base)
#   --platform PLATFORM Build platform, e.g. linux/amd64 (default: $PLATFORM or linux/amd64)
#   --jobs N            Number of parallel Spack build jobs (default: $JOBS or 4)
#   --base-tag TAG      Tag of the base image to use (default: local in local mode, $INTERNAL_TAG in CI)
#   --tag TAG           Local tag for the output image (default: local; ignored in CI)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Defaults (may be overridden by env vars set from CI matrix or command-line flags)
BUILD_IMAGE="${BUILD_IMAGE:-eic_}"
ENV="${ENV:-xl}"
BUILD_TYPE="${BUILD_TYPE:-default}"
BUILDER_IMAGE="${BUILDER_IMAGE:-debian_stable_base}"
RUNTIME_IMAGE="${RUNTIME_IMAGE:-debian_stable_base}"
PLATFORM="${PLATFORM:-linux/amd64}"
JOBS="${JOBS:-4}"
LOCAL_TAG="${LOCAL_TAG:-local}"
LOCAL_BASE_TAG="${LOCAL_BASE_TAG:-local}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)           ENV="$2";           shift 2 ;;
    --build-type)    BUILD_TYPE="$2";    shift 2 ;;
    --builder-image) BUILDER_IMAGE="$2"; shift 2 ;;
    --runtime-image) RUNTIME_IMAGE="$2"; shift 2 ;;
    --platform)      PLATFORM="$2";     shift 2 ;;
    --jobs)          JOBS="$2";         shift 2 ;;
    --base-tag)      LOCAL_BASE_TAG="$2"; shift 2 ;;
    --tag)           LOCAL_TAG="$2";    shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

## Source version files
source "${SCRIPT_DIR}/spack.sh"
source "${SCRIPT_DIR}/spack-packages.sh"
source "${SCRIPT_DIR}/key4hep-spack.sh"
source "${SCRIPT_DIR}/eic-spack.sh"

## Generate mirrors.yaml from template or create a public-only version.
## Uses sed rather than envsubst to avoid a runtime dependency on gettext.
if [ -n "${CI_REGISTRY}" ]; then
  ## CI mode: expand the three CI-specific variables in the template
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
build_cmd+=(${BUILD_OPTIONS})

## Output mode: push in CI, load locally
if [ -n "${CI_REGISTRY}" ]; then
  build_cmd+=(--push)
else
  build_cmd+=(--load)
fi

## Cache sources
CACHE_KEY="${BUILD_IMAGE}${ENV}-${BUILD_TYPE}"
if [ -n "${CI_REGISTRY}" ]; then
  build_cmd+=(--cache-from "type=registry,ref=${CI_REGISTRY}/${CI_PROJECT_PATH}/buildcache:${CACHE_KEY}-${CI_COMMIT_REF_SLUG}-${ARCH}")
fi
if [ -n "${GH_REGISTRY}" ] && [ -n "${GH_REGISTRY_USER}" ]; then
  build_cmd+=(--cache-from "type=registry,ref=${GH_REGISTRY}/${GH_REGISTRY_USER}/buildcache:${CACHE_KEY}-${CI_COMMIT_REF_SLUG:-master}-${ARCH}")
fi
if [ -n "${CI_REGISTRY}" ]; then
  build_cmd+=(--cache-from "type=registry,ref=${CI_REGISTRY}/${CI_PROJECT_PATH}/buildcache:${CACHE_KEY}-${CI_DEFAULT_BRANCH_SLUG}-${ARCH}")
fi
if [ -n "${GH_REGISTRY}" ] && [ -n "${GH_REGISTRY_USER}" ]; then
  build_cmd+=(--cache-from "type=registry,ref=${GH_REGISTRY}/${GH_REGISTRY_USER}/buildcache:${CACHE_KEY}-${CI_DEFAULT_BRANCH_SLUG:-master}-${ARCH}")
fi

## Cache destination (CI only)
if [ -n "${CI_REGISTRY}" ]; then
  build_cmd+=(--cache-to "type=registry,ref=${CI_REGISTRY}/${CI_PROJECT_PATH}/buildcache:${CACHE_KEY}-${CI_COMMIT_REF_SLUG}-${ARCH},mode=max")
fi

## Image tags
if [ -n "${CI_REGISTRY}" ]; then
  ## Always tag with INTERNAL_TAG in CI
  build_cmd+=(--tag "${CI_REGISTRY}/${CI_PROJECT_PATH}/${BUILD_IMAGE}${ENV}:${INTERNAL_TAG}-${BUILD_TYPE}")
  if [ -n "${EXPORT_TAG}" ]; then
    if [ "${BUILD_TYPE}" = "default" ]; then
      [ -n "${CI_PUSH}" ] && build_cmd+=(--tag "${CI_REGISTRY}/${CI_PROJECT_PATH}/${BUILD_IMAGE}${ENV}:${EXPORT_TAG}")
      [ -n "${DH_PUSH}" ] && build_cmd+=(--tag "${DH_REGISTRY}/${DH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${EXPORT_TAG}")
      [ -n "${GH_PUSH}" ] && build_cmd+=(--tag "${GH_REGISTRY}/${GH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${EXPORT_TAG}")
    else
      [ -n "${CI_PUSH}" ] && build_cmd+=(--tag "${CI_REGISTRY}/${CI_PROJECT_PATH}/${BUILD_IMAGE}${ENV}:${EXPORT_TAG}-${BUILD_TYPE}")
      [ -n "${DH_PUSH}" ] && build_cmd+=(--tag "${DH_REGISTRY}/${DH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${EXPORT_TAG}-${BUILD_TYPE}")
      [ -n "${GH_PUSH}" ] && build_cmd+=(--tag "${GH_REGISTRY}/${GH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${EXPORT_TAG}-${BUILD_TYPE}")
    fi
  fi
  ## Nightly tag (BUILD_TYPE=nightly and NIGHTLY flag set)
  if [ "${BUILD_TYPE}" = "nightly" ] && [ -n "${NIGHTLY}" ]; then
    [ -n "${CI_PUSH}" ] && build_cmd+=(--tag "${CI_REGISTRY}/${CI_PROJECT_PATH}/${BUILD_IMAGE}${ENV}:${NIGHTLY_TAG}")
    [ -n "${DH_PUSH}" ] && build_cmd+=(--tag "${DH_REGISTRY}/${DH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${NIGHTLY_TAG}")
    [ -n "${GH_PUSH}" ] && build_cmd+=(--tag "${GH_REGISTRY}/${GH_REGISTRY_USER}/${BUILD_IMAGE}${ENV}:${NIGHTLY_TAG}")
  fi
else
  build_cmd+=(--tag "${BUILD_IMAGE}${ENV}:${LOCAL_TAG}")
fi

## Dockerfile and platform
build_cmd+=(--file containers/eic/Dockerfile)
build_cmd+=(--platform "${PLATFORM}")

## Build arguments
build_cmd+=(--build-arg "BENCHMARK_COM_SHA=${BENCHMARK_COM_SHA}")
build_cmd+=(--build-arg "BENCHMARK_DET_SHA=${BENCHMARK_DET_SHA}")
build_cmd+=(--build-arg "BENCHMARK_REC_SHA=${BENCHMARK_REC_SHA}")
build_cmd+=(--build-arg "BENCHMARK_PHY_SHA=${BENCHMARK_PHY_SHA}")
build_cmd+=(--build-arg "CAMPAIGNS_HEPMC3_SHA=${CAMPAIGNS_HEPMC3_SHA}")
build_cmd+=(--build-arg "CAMPAIGNS_CONDOR_SHA=${CAMPAIGNS_CONDOR_SHA}")
build_cmd+=(--build-arg "CAMPAIGNS_SLURM_SHA=${CAMPAIGNS_SLURM_SHA}")

if [ -n "${CI_REGISTRY}" ]; then
  build_cmd+=(--build-arg "DOCKER_REGISTRY=${CI_REGISTRY}/${CI_PROJECT_PATH}/")
  build_cmd+=(--build-arg "INTERNAL_TAG=${INTERNAL_TAG}")
  build_cmd+=(--build-arg "CI_COMMIT_SHA=${CI_COMMIT_SHA}")
  build_cmd+=(--build-arg "EIC_CONTAINER_VERSION=${EXPORT_TAG}-${BUILD_TYPE}-$(git rev-parse HEAD)")
else
  build_cmd+=(--build-arg "DOCKER_REGISTRY=ghcr.io/eic/")
  build_cmd+=(--build-arg "INTERNAL_TAG=${LOCAL_BASE_TAG}")
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
if [ -n "${CI_REGISTRY}" ]; then
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
set -o xtrace
"${build_cmd[@]}" 2>&1 | tee build.log
