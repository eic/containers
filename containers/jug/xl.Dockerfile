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
ARG JUGGLER_VERSION="main"
ARG EICRECON_VERSION="main"
ARG jobs=8

## version will automatically bust cache for nightly, as it includes
## the date
ARG JUG_VERSION=1

RUN cd /tmp                                                                     \
 && echo " - jug_xl: ${JUG_VERSION}" >> /etc/jug_info

ADD ${EICWEB}/369/repository/tree?ref=${JUGGLER_VERSION} /tmp/369.json
RUN --mount=type=cache,target=/ccache/,sharing=locked,id=${TARGETPLATFORM}      \
    cd /tmp                                                                     \
 && echo "INSTALLING JUGGLER"                                                   \
 && git clone -b ${JUGGLER_VERSION} --depth 1                                   \
        https://eicweb.phy.anl.gov/EIC/juggler.git                              \
 && export CCACHE_DIR=/ccache                                                   \     
 && cmake -B build -S juggler                                                   \
          -DCMAKE_CXX_FLAGS="-Wno-psabi"                                        \
          -DCMAKE_CXX_STANDARD=17                                               \
          -DCMAKE_INSTALL_PREFIX=/usr/local                                     \
          -DCMAKE_BUILD_TYPE=Release                                            \
          -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
 && cmake --build build -j${jobs} -- install                                    \
 && pushd juggler                                                               \
 && echo " - juggler: ${JUGGLER_VERSION}-$(git rev-parse HEAD)"                 \
          >> /etc/jug_info                                                      \
 && popd                                                                        \
 && rm -rf build juggler

ADD https://api.github.com/repos/eic/eicrecon/commits/${EICRECON_VERSION} /tmp/eicrecon.json
RUN --mount=type=cache,target=/ccache/,sharing=locked,id=${TARGETPLATFORM}      \
    cd /tmp                                                                     \
 && echo "INSTALLING EICRECON"                                                  \
 && git clone -b ${EICRECON_VERSION} --depth 1                                  \
        https://github.com/eic/eicrecon.git                                     \
 && export CCACHE_DIR=/ccache                                                   \
 && cmake -B build -S eicrecon                                                  \
          -DCMAKE_CXX_FLAGS="-Wno-psabi"                                        \
          -DCMAKE_CXX_STANDARD=17                                               \
          -DCMAKE_INSTALL_PREFIX=/usr/local                                     \
          -DCMAKE_BUILD_TYPE=Release                                            \
          -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
 && cmake --build build -j${jobs} -- install                                    \
 && pushd eicrecon                                                              \
 && echo " - eicrecon: ${EICRECON_VERSION}-$(git rev-parse HEAD)"               \
          >> /etc/jug_info                                                      \
 && echo "export JANA_PLUGIN_PATH=/usr/local/lib/EICrecon/plugins"              \
    > /etc/profile.d/z12_eicrecon.sh                                            \
 && popd                                                                        \
 && rm -rf build eicrecon

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
ADD https://api.github.com/repos/eic/simulation_campaign_single/commits/${CAMPAIGNS_SINGLE_VERSION} /tmp/simulation_campaign_single.json
ADD https://api.github.com/repos/eic/simulation_campaign_hepmc3/commits/${CAMPAIGNS_HEPMC3_VERSION} /tmp/simulation_campaign_hepmc3.json
ADD https://api.github.com/repos/eic/job_submission_condor/commits/${CAMPAIGNS_CONDOR_VERSION} /tmp/job_submission_condor.json
ADD https://api.github.com/repos/eic/job_submission_slurm/commits/${CAMPAIGNS_SLURM_VERSION} /tmp/job_submission_slurm.json
RUN mkdir -p /opt/campaigns                                                     \
 && cd /opt/campaigns                                                           \
 && git clone -b ${CAMPAIGNS_SINGLE_VERSION} --depth 1                          \
        https://github.com/eic/simulation_campaign_single.git single            \
 && mkdir -p /opt/campaigns                                                     \
 && cd /opt/campaigns                                                           \
 && git clone -b ${CAMPAIGNS_HEPMC3_VERSION} --depth 1                          \
        https://github.com/eic/simulation_campaign_hepmc3.git hepmc3            \
 && mkdir -p /opt/campaigns                                                     \
 && cd /opt/campaigns                                                           \
 && git clone -b ${CAMPAIGNS_CONDOR_VERSION} --depth 1                          \
        https://github.com/eic/job_submission_condor.git condor                 \
 && mkdir -p /opt/campaigns                                                     \
 && cd /opt/campaigns                                                           \
 && git clone -b ${CAMPAIGNS_SLURM_VERSION} --depth 1                           \
        https://github.com/eic/job_submission_slurm.git slurm
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

## eic-news
COPY --chmod=0755 eic-news /usr/local/bin/eic-news
RUN echo "test -f $HOME/.eic-news && source /usr/local/bin/eic-news"            \
    > /etc/profile.d/z13_eic-news.sh 

## Hotfix for misbehaving OSG nodes
RUN mkdir /hadoop

## create local user `eic` with lower privileges for use in docker
RUN useradd --create-home --shell /bin/bash eic
USER eic
WORKDIR /home/eic
