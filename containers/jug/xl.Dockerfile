#syntax=docker/dockerfile:1.4
ARG DOCKER_REGISTRY="eicweb/"
ARG BASE_IMAGE="jug_dev"
ARG INTERNAL_TAG="testing"

## ========================================================================================
## STAGE1: spack builder image
## EIC builder image with spack
## ========================================================================================
FROM ${DOCKER_REGISTRY}${BASE_IMAGE}:${INTERNAL_TAG}
ARG TARGETPLATFORM

ARG EICWEB="https://eicweb.phy.anl.gov/api/v4/projects"
ARG jobs=8

## version will automatically bust cache for nightly, as it includes
## the date
ARG JUG_VERSION=1

RUN cd /tmp                                                                     \
 && echo " - jug_xl: ${JUG_VERSION}" >> /etc/jug_info

## also install detector/ip geometries into opt
ARG NIGHTLY=''
## cache bust when updated repositories
# - just master on eicweb (FIXME too narrow)
ADD ${EICWEB}/473/repository/tree?ref=master /tmp/473.json
ADD ${EICWEB}/452/repository/tree?ref=master /tmp/452.json
# - all branches for ip6 and epic on github
ADD https://api.github.com/repos/eic/ip6 /tmp/ip6.json
ADD https://api.github.com/repos/eic/epic /tmp/epic.json
COPY setup_detectors.py /tmp
COPY --from=detectors detectors.yaml /tmp
RUN --mount=type=cache,target=/ccache/,sharing=locked,id=${TARGETPLATFORM}      \
    cd /tmp                                                                     \
 && export CCACHE_DIR=/ccache                                                   \
 && [ "z$NIGHTLY" = "z1" ] && NIGHTLY_FLAG="--nightly" || NIGHTLY_FLAG=""       \
 && /tmp/setup_detectors.py --prefix /opt/detector --config /tmp/detectors.yaml \
                         $NIGHTLY_FLAG                                          \
 && ccache --show-stats                                                         \
 && rm /tmp/setup_detectors.py
