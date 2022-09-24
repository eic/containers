#syntax=docker/dockerfile:1.2
ARG DOCKER_REGISTRY="eicweb.phy.anl.gov:4567/containers/eic_container/"
ARG INTERNAL_TAG="testing"
ARG BASEIMAGE="jug_dev"

## ========================================================================================
## STAGE1: spack builder image
## EIC builder image with spack
## ========================================================================================
FROM ${DOCKER_REGISTRY}${BASEIMAGE}:${INTERNAL_TAG}

ARG EICWEB="https://eicweb.phy.anl.gov/api/v4/projects"
ARG JUGGLER_VERSION="main"
ARG NPDET_VERSION="master"

## version will automatically bust cache for nightly, as it includes
## the date
ARG JUG_VERSION=1

ADD ${EICWEB}/18/repository/tree?ref=${NPDET_VERSION} /tmp/18.json
RUN cd /tmp                                                                     \
 && echo " - jug_xl: ${JUG_VERSION}" >> /etc/jug_info                           \
 && echo "INSTALLING NPDET"                                                     \
 && git config --global http.version HTTP/1.1                                   \
 && git clone -b ${NPDET_VERSION} --depth 1                                     \
        https://eicweb.phy.anl.gov/EIC/NPDet.git                                \
 && cmake -B build -S NPDet -DCMAKE_CXX_STANDARD=17                             \
 && cmake --build build -j12 -- install                                         \
 && pushd NPDet                                                                 \
 && echo " - NPDet: ${NPDET_VERSION}-$(git rev-parse HEAD)">> /etc/jug_info     \
 && popd                                                                        \
 && rm -rf build NPDet

ADD ${EICWEB}/369/repository/tree?ref=${JUGGLER_VERSION} /tmp/369.json
RUN cd /tmp                                                                     \
 && echo "INSTALLING JUGGLER"                                                   \
 && git clone -b ${JUGGLER_VERSION} --depth 1                                   \
        https://eicweb.phy.anl.gov/EIC/juggler.git                              \
 && cmake -B build -S juggler                                                   \
          -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX=/usr/local             \
 && cmake --build build -j12 -- install                                         \
 && pushd juggler                                                               \
 && echo " - Juggler: ${JUGGLER_VERSION}-$(git rev-parse HEAD)"                 \
          >> /etc/jug_info                                                      \
 && popd                                                                        \
 && rm -rf build juggler

## Install benchmarks into the container
ARG BENCHMARK_COM_VERSION="master"
ARG BENCHMARK_DET_VERSION="master"
ARG BENCHMARK_REC_VERSION="master"
ARG BENCHMARK_PHY_VERSION="master"
## cache bust when updated repositories
ADD ${EICWEB}/458/repository/tree?ref=${BENCHMARK_COM_VERSION} /tmp/485.json
ADD ${EICWEB}/399/repository/tree?ref=${BENCHMARK_DET_VERSION} /tmp/399.json
ADD ${EICWEB}/408/repository/tree?ref=${BENCHMARK_REC_VERSION} /tmp/408.json 
ADD ${EICWEB}/400/repository/tree?ref=${BENCHMARK_PHY_VERSION} /tmp/400.json
RUN mkdir -p /opt/benchmarks                                                    \
 && cd /opt/benchmarks                                                          \
 && git clone -b ${BENCHMARK_COM_VERSION} --depth 1                             \
        https://eicweb.phy.anl.gov/EIC/benchmarks/common_bench.git              \
 && mkdir -p /opt/benchmarks                                                    \
 && cd /opt/benchmarks                                                          \
 && git clone -b ${BENCHMARK_DET_VERSION} --depth 1                             \
        https://eicweb.phy.anl.gov/EIC/benchmarks/detector_benchmarks.git       \
 && ln -sf ../common_bench detector_benchmarks/.local                           \
 && mkdir -p /opt/benchmarks                                                    \
 && cd /opt/benchmarks                                                          \
 && git clone -b ${BENCHMARK_REC_VERSION} --depth 1                             \
        https://eicweb.phy.anl.gov/EIC/benchmarks/reconstruction_benchmarks.git \
 && ln -sf ../common_bench reconstruction_benchmarks/.local                     \
 && mkdir -p /opt/benchmarks                                                    \
 && cd /opt/benchmarks                                                          \
 && git clone -b ${BENCHMARK_PHY_VERSION} --depth 1                             \
        https://eicweb.phy.anl.gov/EIC/benchmarks/physics_benchmarks.git        \
 && ln -sf ../common_bench physics_benchmarks/.local

## Install campaigns into the container
ARG CAMPAIGNS_SINGLE_VERSION="main"
ARG CAMPAIGNS_HEPMC3_VERSION="main"
ARG CAMPAIGNS_CONDOR_VERSION="main"
ARG CAMPAIGNS_SLURM_VERSION="main"
## cache bust when updated repositories
ADD ${EICWEB}/482/repository/tree?ref=${CAMPAIGNS_SINGLE_VERSION} /tmp/482.json
ADD ${EICWEB}/483/repository/tree?ref=${CAMPAIGNS_HEPMC3_VERSION} /tmp/483.json
ADD ${EICWEB}/484/repository/tree?ref=${CAMPAIGNS_CONDOR_VERSION} /tmp/484.json
ADD ${EICWEB}/485/repository/tree?ref=${CAMPAIGNS_SLURM_VERSION} /tmp/485.json
RUN mkdir -p /opt/campaigns                                                     \
 && cd /opt/campaigns                                                           \
 && git clone -b ${CAMPAIGNS_SINGLE_VERSION} --depth 1                          \
        https://eicweb.phy.anl.gov/EIC/campaigns/single.git                     \
 && mkdir -p /opt/campaigns                                                     \
 && cd /opt/campaigns                                                           \
 && git clone -b ${CAMPAIGNS_HEPMC3_VERSION} --depth 1                          \
        https://eicweb.phy.anl.gov/EIC/campaigns/hepmc3.git                     \
 && mkdir -p /opt/campaigns                                                     \
 && cd /opt/campaigns                                                           \
 && git clone -b ${CAMPAIGNS_CONDOR_VERSION} --depth 1                          \
        https://eicweb.phy.anl.gov/EIC/campaigns/condor.git                     \
 && mkdir -p /opt/campaigns                                                     \
 && cd /opt/campaigns                                                           \
 && git clone -b ${CAMPAIGNS_SLURM_VERSION} --depth 1                           \
        https://eicweb.phy.anl.gov/EIC/campaigns/slurm.git

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
COPY detectors.yaml /tmp
RUN cd /tmp                                                                     \
 && [ "z$NIGHTLY" = "z1" ] && NIGHTLY_FLAG="--nightly" || NIGHTLY_FLAG=""       \
 && /tmp/setup_detectors.py --prefix /opt/detector --config /tmp/detectors.yaml \
                         $NIGHTLY_FLAG                                          \
 && rm /tmp/setup_detectors.py
