#syntax=docker/dockerfile:1.4
ARG DOCKER_REGISTRY="eicweb/"
ARG BASE_IMAGE="debian_stable_base"
ARG INTERNAL_TAG="testing"

## ========================================================================================
## STAGE1: spack builder image
## EIC builder image with spack
## ========================================================================================
FROM ${DOCKER_REGISTRY}${BASE_IMAGE}:${INTERNAL_TAG} as builder
ARG TARGETPLATFORM

## install some extra spack dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=${TARGETPLATFORM} \
    rm -f /etc/apt/apt.conf.d/docker-clean                              \
 && apt-get -yqq update                                                 \
 && apt-get -yqq install --no-install-recommends                        \
        python3                                                         \
        python3-dev                                                     \
        python3-distutils                                               \
        python3-boto3                                                   \
        python-is-python3                                               \
 && rm -rf /var/lib/apt/lists/*

## Setup spack
ENV SPACK_ROOT=/opt/spack
ARG SPACK_ORGREPO="spack/spack"
ARG SPACK_VERSION="releases/v0.20"
ARG SPACK_CHERRYPICKS=""
ADD https://api.github.com/repos/${SPACK_ORGREPO}/commits/${SPACK_VERSION} /tmp/spack.json
RUN git clone https://github.com/${SPACK_ORGREPO}.git ${SPACK_ROOT}     \
 && git -C ${SPACK_ROOT} checkout ${SPACK_VERSION}                      \
 && if [ -n "${SPACK_CHERRYPICKS}" ] ; then                             \
      git -C ${SPACK_ROOT} cherry-pick -n ${SPACK_CHERRYPICKS} ;        \
    fi                                                                  \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash                \
          /usr/bin/docker-shell                                         \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash                \
          /usr/bin/interactive-shell                                    \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash                \
          /usr/bin/spack-env

SHELL ["docker-shell"]

ARG jobs=64
RUN declare -A target=(                                                 \
      ["linux/amd64"]="x86_64_v2"                                       \
      ["linux/arm64"]="aarch64"                                         \
    )                                                                   \
 && target=${target[${TARGETPLATFORM}]}                                 \
 && spack config --scope site add "packages:all:require:[target=${target}]" \
 && spack config blame packages                                         \
 && spack config --scope site add "config:suppress_gpg_warnings:true"   \
 && spack config --scope site add "config:build_jobs:${jobs}"           \
 && spack config --scope site add "config:db_lock_timeout:${jobs}0"     \
 && spack config --scope site add "config:install_tree:root:/opt/software" \
 && spack config --scope site add "config:source_cache:/var/cache/spack" \
 && spack config --scope site add "config:ccache:true"                  \
 && spack config blame config                                           \
 && spack compiler find --scope site                                    \
 && spack config blame compilers

## Setup local buildcache mirrors
RUN --mount=type=cache,target=/var/cache/spack-mirror                   \
    spack mirror add local /var/cache/spack-mirror/${SPACK_VERSION}     \
 && spack buildcache update-index local                                 \
 && spack mirror list

## Setup eics3 buildcache mirrors
## - this always adds the read-only mirror to the container
## - the write-enabled mirror is provided later as a secret mount
ARG S3_ACCESS_KEY=""
ARG S3_SECRET_KEY=""
RUN --mount=type=cache,target=/var/cache/spack-mirror                   \
    if [ -n "${S3_ACCESS_KEY}" ] ; then                                 \
    spack mirror add --scope site                                       \
      --s3-endpoint-url https://eics3.sdcc.bnl.gov:9000                 \
      --s3-access-key-id "${S3_ACCESS_KEY}"                             \
      --s3-access-key-secret "${S3_SECRET_KEY}"                         \
      eics3 s3://eictest/EPIC/spack/${SPACK_VERSION}                    \
    ; fi                                                                \
 && spack mirror list

## This variable will change whenever either spack.yaml or our spack package
## overrides change, triggering a rebuild
ARG CACHE_BUST="hash"
ARG CACHE_NUKE=""

## Setup our custom package overrides
ENV EICSPACK_ROOT=${SPACK_ROOT}/var/spack/repos/eic-spack
ARG EICSPACK_ORGREPO="eic/eic-spack"
ARG EICSPACK_VERSION="$SPACK_VERSION"
ARG EICSPACK_CHERRYPICKS=""
ADD https://api.github.com/repos/${EICSPACK_ORGREPO}/commits/${EICSPACK_VERSION} /tmp/eic-spack.json
RUN git clone https://github.com/${EICSPACK_ORGREPO}.git ${EICSPACK_ROOT} \
 && git -C ${EICSPACK_ROOT} checkout ${EICSPACK_VERSION}                \
 && if [ -n "${EICSPACK_CHERRYPICKS}" ] ; then                          \
      git -C ${EICSPACK_ROOT} cherry-pick -n ${EICSPACK_CHERRYPICKS} ;  \
    fi                                                                  \
 && spack repo add --scope site "${EICSPACK_ROOT}"

