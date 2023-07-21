#syntax=docker/dockerfile:1.4
ARG DOCKER_REGISTRY="eicweb/"
ARG BASE_IMAGE="debian_stable_base"
ARG INTERNAL_TAG="testing"

## ========================================================================================
## STAGE0: spack image
## EIC spack image with spack and eic-spack repositories
## ========================================================================================
FROM ${DOCKER_REGISTRY}${BASE_IMAGE}:${INTERNAL_TAG} as spack
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
        python-is-python3

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

## ========================================================================================
## STAGE1: builder
## EIC builder image with spack environment
## ========================================================================================
FROM spack as builder

## Setup our custom environment (secret mount for write-enabled mirror)
COPY --from=spack-environment . /opt/spack-environment/
ARG ENV=dev
ENV SPACK_ENV=/opt/spack-environment/${ENV}
RUN --mount=type=cache,target=/ccache,id=${TARGETPLATFORM}              \
    --mount=type=cache,target=/var/cache/spack-mirror                   \
    --mount=type=secret,id=mirrors,target=/opt/spack/etc/spack/mirrors.yaml \
    source $SPACK_ROOT/share/spack/setup-env.sh                         \
 && export CCACHE_DIR=/ccache                                           \
 && spack env activate --dir ${SPACK_ENV}                               \
 && make --jobs ${jobs} --keep-going --directory /opt/spack-environment \
    SPACK_ENV=${SPACK_ENV}                                              \
    BUILDCACHE_MIRROR="local eics3rw"                                   \
 && ccache --show-stats

## Create view at /usr/local
RUN --mount=type=cache,target=/var/cache/spack-mirror                   \
    source $SPACK_ROOT/share/spack/setup-env.sh                         \
 && spack env activate --dir ${SPACK_ENV}                               \
 && rm -r /usr/local                                                    \
 && spack env view enable /usr/local

## Optional, nuke the buildcache after install, before (re)caching
## This is useful when going to completely different containers,
## or intermittently to keep the buildcache step from taking too much time
ARG CACHE_NUKE=""
RUN --mount=type=cache,target=/var/cache/spack-mirror,sharing=locked    \
    [ -z "${CACHE_NUKE}" ]                                              \
    || rm -rf /var/cache/spack-mirror/${SPACK_VERSION}/build_cache/*

## Extra post-spack steps:
##   - Python packages
COPY requirements.txt /usr/local/etc/requirements.txt
RUN --mount=type=cache,target=/var/cache/pip,sharing=locked,id=${TARGETPLATFORM} \
    echo "Installing additional python packages"                        \
 && source $SPACK_ROOT/share/spack/setup-env.sh                         \
 && spack env activate --dir ${SPACK_ENV}                               \
 && python -m pip install                                               \
    --trusted-host pypi.org                                             \
    --trusted-host files.pythonhosted.org                               \
    --cache-dir /var/cache/pip                                          \
    --requirement /usr/local/etc/requirements.txt                       \
    --no-warn-script-location
    # ^ Supress not on PATH Warnings

## Including some small fixes
RUN echo "Grabbing environment info"                                    \
 && spack env activate --sh --dir ${SPACK_ENV}                          \
    > /etc/profile.d/z10_spack_environment.sh

## make sure we have the entrypoints setup correctly
ENTRYPOINT []
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /

## ========================================================================================
## STAGE 2: staging image with unnecessariy packages removed and stripped binaries
## ========================================================================================
FROM builder as staging

# Garbage collect in environment
RUN spack -e ${SPACK_ENV} gc -y

# Garbage collect in git
RUN du -sh $SPACK_ROOT                                                  \
 && git -C $SPACK_ROOT fetch --depth=1                                  \
 && git -C $SPACK_ROOT gc --prune=all --aggressive                      \
 && du -sh $SPACK_ROOT

## Bugfix to address issues loading the Qt5 libraries on Linux kernels prior to 3.15
## See
#https://askubuntu.com/questions/1034313/ubuntu-18-4-libqt5core-so-5-cannot-open-shared-object-file-no-such-file-or-dir
## and links therin for more info
RUN if [ -f /usr/local/lib/libQt5Core.so ] ; then                       \
      strip --remove-section=.note.ABI-tag /usr/local/lib/libQt5Core.so;\
    fi

RUN spack debug report                                                  \
      | sed "s/^/ - /" | sed "s/\* \*\*//" | sed "s/\*\*//"             \
    >> /etc/jug_info                                                    \
 && spack find --no-groups --long --variants | sed "s/^/ - /" >> /etc/jug_info \
 && spack graph --dot --installed > /opt/spack-environment/env.dot


COPY eic-shell /usr/local/bin/eic-shell
COPY eic-info /usr/local/bin/eic-info
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
COPY eic-env.sh /etc/eic-env.sh
COPY profile.d/a00_cleanup.sh /etc/profile.d
COPY profile.d/z11_jug_env.sh /etc/profile.d
COPY singularity.d /.singularity.d

## Add minio client into /usr/local/bin
ADD --chmod=0755 https://dl.min.io/client/mc/release/linux-amd64/mc /usr/local/bin/mc-amd64
ADD --chmod=0755 https://dl.min.io/client/mc/release/linux-arm64/mc /usr/local/bin/mc-arm64
RUN declare -A target=(                                                 \
      ["linux/amd64"]="amd64"                                           \
      ["linux/arm64"]="arm64"                                           \
    )                                                                   \
 && mv /usr/local/bin/mc-${target[${TARGETPLATFORM}]} /usr/local/bin/mc \
 && unset target[${TARGETPLATFORM}]                                     \
 && for t in ${target[*]} ; do                                          \
      rm /usr/local/bin/mc-${t} ;                                       \
    done

## ========================================================================================
## STAGE 3
## Lean target image
## ========================================================================================
FROM ${DOCKER_REGISTRY}${BASE_IMAGE}:${INTERNAL_TAG} as export
ARG TARGETPLATFORM

LABEL maintainer="Sylvester Joosten <sjoosten@anl.gov>" \
      name="jug_xl" \
      march="$TARGETPLATFORM"

## copy over everything we need from staging in a single layer :-)
RUN --mount=from=staging,target=/staging                                \
    rm -rf /usr/local                                                   \
 && cp -r /staging/opt/spack /opt/spack                                 \
 && cp -r /staging/opt/spack-environment /opt/spack-environment         \
 && cp -r /staging/opt/software /opt/software                           \
 && cp -r /staging/usr/._local /usr/._local                             \
 && cd /usr/._local                                                     \
 && PREFIX_PATH=$(realpath $(ls | tail -n1))                            \
 && echo "Found spack true prefix path to be $PREFIX_PATH"              \
 && cd -                                                                \
 && ln -s ${PREFIX_PATH} /usr/local                                     \
 && cp /staging/etc/profile.d/*.sh /etc/profile.d/                      \
 && cp /staging/etc/eic-env.sh /etc/eic-env.sh                          \
 && cp /staging/etc/jug_info /etc/jug_info                              \
 && cp -r /staging/.singularity.d /.singularity.d                        

## set the jug_dev version and add the afterburner
ARG JUG_VERSION=1
RUN echo "" >> /etc/jug_info                                            \
 && echo " - jug_dev: ${JUG_VERSION}" >> /etc/jug_info

## make sure we have the entrypoints setup correctly
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /
SHELL ["/usr/local/bin/eic-shell"]
