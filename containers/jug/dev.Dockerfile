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

## With heredocs for multi-line scripts, we want to fail on error and the print failing line.
## Ref: https://docs.docker.com/engine/reference/builder/#example-running-a-multi-line-script
SHELL ["bash", "-ex", "-c"]

## install some extra spack dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=${TARGETPLATFORM} <<EOF
rm -f /etc/apt/apt.conf.d/docker-clean
apt-get -yqq update
apt-get -yqq install --no-install-recommends                            \
        python3                                                         \
        python3-dev                                                     \
        python3-distutils                                               \
        python3-boto3                                                   \
        python-is-python3
EOF

## Setup spack
ENV SPACK_ROOT=/opt/spack
ARG SPACK_ORGREPO="spack/spack"
ARG SPACK_VERSION="releases/v0.20"
ARG SPACK_CHERRYPICKS=""
ADD https://api.github.com/repos/${SPACK_ORGREPO}/commits/${SPACK_VERSION} /tmp/spack.json
RUN <<EOF
git clone --filter=tree:0 https://github.com/${SPACK_ORGREPO}.git ${SPACK_ROOT}
git -C ${SPACK_ROOT} checkout ${SPACK_VERSION}
if [ -n "${SPACK_CHERRYPICKS}" ] ; then
  SPACK_CHERRYPICKS=$(git -C ${SPACK_ROOT} rev-list --topo-order ${SPACK_CHERRYPICKS} | grep -m $(echo ${SPACK_CHERRYPICKS} | wc -w)  "${SPACK_CHERRYPICKS}" | tac)
  git -C ${SPACK_ROOT} cherry-pick -n ${SPACK_CHERRYPICKS}
fi
ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash /usr/bin/docker-shell
ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash /usr/bin/interactive-shell
ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash /usr/bin/spack-env
EOF

## Use spack entrypoint. NOTE: Requires `set -ex` in all multi-line scripts!
SHELL ["docker-shell"]

## Setup build configuration
ARG jobs=64
RUN <<EOF
set -ex
declare -A target=(["linux/amd64"]="x86_64_v2" ["linux/arm64"]="aarch64")
target=${target[${TARGETPLATFORM}]}
spack config --scope site add "packages:all:require:[target=${target}]"
spack config --scope site add "packages:all:target:[${target}]"
spack config blame packages
spack config --scope user add "config:suppress_gpg_warnings:true"
spack config --scope user add "config:build_jobs:${jobs}"
spack config --scope user add "config:db_lock_timeout:${jobs}00"
spack config --scope user add "config:source_cache:/var/cache/spack"
spack config --scope user add "config:install_tree:root:/opt/software"
spack config --scope user add "config:ccache:true"
spack config blame config
spack compiler find --scope site
spack config blame compilers
EOF

## Setup local buildcache mirrors
RUN --mount=type=cache,target=/var/cache/spack <<EOF
set -ex
spack mirror add local /var/cache/spack/mirror/${SPACK_VERSION}
spack buildcache update-index local
spack mirror list
EOF

## Setup eics3 buildcache mirrors
## - this always adds the read-only mirror to the container
## - the write-enabled mirror is provided later as a secret mount
ARG S3_ACCESS_KEY=""
ARG S3_SECRET_KEY=""
RUN --mount=type=cache,target=/var/cache/spack <<EOF
set -ex
if [ -n "${S3_ACCESS_KEY}" ] ; then
  spack mirror add --scope site                                         \
      --s3-endpoint-url https://eics3.sdcc.bnl.gov:9000                 \
      --s3-access-key-id "${S3_ACCESS_KEY}"                             \
      --s3-access-key-secret "${S3_SECRET_KEY}"                         \
      eics3 s3://eictest/EPIC/spack/${SPACK_VERSION}
fi
spack mirror list
EOF

## Setup eic-spack
ENV EICSPACK_ROOT=${SPACK_ROOT}/var/spack/repos/eic-spack
ARG EICSPACK_ORGREPO="eic/eic-spack"
ARG EICSPACK_VERSION="$SPACK_VERSION"
ARG EICSPACK_CHERRYPICKS=""
ADD https://api.github.com/repos/${EICSPACK_ORGREPO}/commits/${EICSPACK_VERSION} /tmp/eic-spack.json
RUN <<EOF
set -ex
git clone --filter=tree:0 https://github.com/${EICSPACK_ORGREPO}.git ${EICSPACK_ROOT}
git -C ${EICSPACK_ROOT} checkout ${EICSPACK_VERSION}
if [ -n "${EICSPACK_CHERRYPICKS}" ] ; then
  git -C ${EICSPACK_ROOT} cherry-pick -n ${EICSPACK_CHERRYPICKS}
fi
spack repo add --scope site "${EICSPACK_ROOT}"
EOF

## Setup key4hep-spack
ENV KEY4HEPSPACK_ROOT=${SPACK_ROOT}/var/spack/repos/key4hep-spack
ARG KEY4HEPSPACK_ORGREPO="key4hep/key4hep-spack"
ARG KEY4HEPSPACK_VERSION="main"
ADD https://api.github.com/repos/${KEY4HEPSPACK_ORGREPO}/commits/${KEY4HEPSPACK_VERSION} /tmp/key4hep-spack.json
RUN <<EOF
set -ex
git clone --filter=tree:0 https://github.com/${KEY4HEPSPACK_ORGREPO}.git ${KEY4HEPSPACK_ROOT}
git -C ${KEY4HEPSPACK_ROOT} checkout ${KEY4HEPSPACK_VERSION}
spack repo add --scope site "${KEY4HEPSPACK_ROOT}"
EOF


## ========================================================================================
## STAGE1: builder
## EIC builder image with spack environment
## ========================================================================================
FROM spack as builder

## Setup our custom environment (secret mount for write-enabled mirror)
COPY --from=spack-environment . /opt/spack-environment/
ARG ENV=dev
ARG JUGGLER_VERSION="main"
ADD https://eicweb.phy.anl.gov/api/v4/projects/EIC%2Fjuggler/repository/tree?ref=${JUGGLER_VERSION} /tmp/juggler.json
ARG EICRECON_VERSION="main"
ADD https://api.github.com/repos/eic/eicrecon/commits/${EICRECON_VERSION} /tmp/eicrecon.json
ENV SPACK_ENV=/opt/spack-environment/${ENV}
RUN --mount=type=cache,target=/ccache,id=${TARGETPLATFORM}              \
    --mount=type=cache,target=/var/cache/spack                          \
    --mount=type=secret,id=mirrors,target=/opt/spack/etc/spack/mirrors.yaml \
    <<EOF
set -ex
export CCACHE_DIR=/ccache
spack buildcache update-index local
spack buildcache update-index eics3rw
spack env activate --dir ${SPACK_ENV}
spack add juggler@git.${JUGGLER_VERSION}
spack add eicrecon@git.${EICRECON_VERSION}
spack concretize --fresh --force --quiet
make --jobs ${jobs} --keep-going --directory /opt/spack-environment SPACK_ENV=${SPACK_ENV} BUILDCACHE_MIRROR="local eics3rw"
ccache --show-stats
ccache --zero-stats
EOF

## Create view at /usr/local
RUN --mount=type=cache,target=/var/cache/spack <<EOF
set -ex
spack env activate --dir ${SPACK_ENV}
rm -r /usr/local
spack env view enable /usr/local
EOF

## Optional, nuke the buildcache after install, before (re)caching
## This is useful when going to completely different containers,
## or intermittently to keep the buildcache step from taking too much time
ARG CACHE_NUKE=""
RUN --mount=type=cache,target=/var/cache/spack,sharing=locked <<EOF
[ -z "${CACHE_NUKE}" ] || rm -rf /var/cache/spack/mirror/${SPACK_VERSION}/build_cache/*
EOF

## Store environment
RUN <<EOF
set -ex
spack env activate --sh --dir ${SPACK_ENV} > /etc/profile.d/z10_spack_environment.sh
EOF

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
RUN git -C $SPACK_ROOT gc --prune=all --aggressive

## Bugfix to address issues loading the Qt5 libraries on Linux kernels prior to 3.15
## See
#https://askubuntu.com/questions/1034313/ubuntu-18-4-libqt5core-so-5-cannot-open-shared-object-file-no-such-file-or-dir
## and links therin for more info
RUN <<EOF
set -ex
if [ -f /usr/local/lib/libQt5Core.so ] ; then
  strip --remove-section=.note.ABI-tag /usr/local/lib/libQt5Core.so
fi
EOF

RUN <<EOF
set -ex
spack debug report | sed "s/^/ - /" | sed "s/\* \*\*//" | sed "s/\*\*//" >> /etc/jug_info
spack find --no-groups --long --variants | sed "s/^/ - /" >> /etc/jug_info
spack graph --dot --installed > /opt/spack-environment/env.dot
EOF

## Copy custom content
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
RUN <<EOF
set -ex
declare -A target=(["linux/amd64"]="amd64" ["linux/arm64"]="arm64")
mv /usr/local/bin/mc-${target[${TARGETPLATFORM}]} /usr/local/bin/mc
unset target[${TARGETPLATFORM}]
for t in ${target[*]} ; do
  rm /usr/local/bin/mc-${t}
done
EOF


## ========================================================================================
## STAGE 3
## Lean target image
## ========================================================================================
FROM ${DOCKER_REGISTRY}${BASE_IMAGE}:${INTERNAL_TAG} as export
ARG TARGETPLATFORM

LABEL maintainer="Sylvester Joosten <sjoosten@anl.gov>" \
      name="jug_xl" \
      march="$TARGETPLATFORM"

## copy over everything we need from staging
COPY --from=staging /opt/spack /opt/spack
COPY --from=staging /opt/spack-environment /opt/spack-environment
COPY --from=staging /opt/software /opt/software
COPY --from=staging /usr/._local /usr/._local
COPY --from=staging /etc/profile.d /etc/profile.d
COPY --from=staging /etc/jug_info /etc/jug_info
COPY --from=staging /etc/eic-env.sh /etc/eic-env.sh
COPY --from=staging /.singularity.d /.singularity.d
COPY --from=staging /usr/bin/docker-shell /usr/bin/docker-shell

## Use spack entrypoint. NOTE: Requires `set -ex` in all multi-line scripts!
ENV SPACK_ROOT=/opt/spack
SHELL ["docker-shell"]

## ensure /usr/local link is pointing to the right view
RUN <<EOF
set -ex
rm -rf /usr/local
PREFIX_PATH=$(realpath $(ls /usr/._local/ | tail -n1))
echo "Found spack true prefix path to be $PREFIX_PATH"
ln -s /usr/._local/${PREFIX_PATH} /usr/local
EOF

## set the local spack configuration
ENV SPACK_DISABLE_LOCAL_CONFIG="true"
RUN <<EOF
set -ex
spack config --scope site add "config:install_tree:root:~/spack"
spack config --scope site add "config:source_cache:~/.spack/cache"
spack config --scope site add "config:binary_index_root:~/.spack"
spack config --scope site add "config:environments_root:~/.spack/env"
spack config --scope site add "config:suppress_gpg_warnings:true"
spack config blame config
spack config --scope site add "upstreams:eic-shell:install_tree:/opt/software"
spack config blame upstreams
EOF

## set the jug_dev version and add the afterburner
ARG JUG_VERSION=1
RUN echo -e "\n - jug_dev: ${JUG_VERSION}" >> /etc/jug_info

## eicweb shortcut
ARG EICWEB="https://eicweb.phy.anl.gov/api/v4/projects"

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
RUN <<EOF
set -ex
mkdir -p /opt/benchmarks
cd /opt/benchmarks
git clone -b ${BENCHMARK_COM_VERSION} --depth 1 https://eicweb.phy.anl.gov/EIC/benchmarks/common_bench.git
git clone -b ${BENCHMARK_DET_VERSION} --depth 1 https://eicweb.phy.anl.gov/EIC/benchmarks/detector_benchmarks.git
ln -sf ../common_bench detector_benchmarks/.local
git clone -b ${BENCHMARK_REC_VERSION} --depth 1 https://eicweb.phy.anl.gov/EIC/benchmarks/reconstruction_benchmarks.git
ln -sf ../common_bench reconstruction_benchmarks/.local
git clone -b ${BENCHMARK_PHY_VERSION} --depth 1 https://eicweb.phy.anl.gov/EIC/benchmarks/physics_benchmarks.git
ln -sf ../common_bench physics_benchmarks/.local
EOF

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
RUN <<EOF
set -ex
mkdir -p /opt/campaigns
cd /opt/campaigns
git clone -b ${CAMPAIGNS_SINGLE_VERSION} --depth 1 https://github.com/eic/simulation_campaign_single.git single
git clone -b ${CAMPAIGNS_HEPMC3_VERSION} --depth 1 https://github.com/eic/simulation_campaign_hepmc3.git hepmc3
git clone -b ${CAMPAIGNS_CONDOR_VERSION} --depth 1 https://github.com/eic/job_submission_condor.git condor
git clone -b ${CAMPAIGNS_SLURM_VERSION} --depth 1 https://github.com/eic/job_submission_slurm.git slurm
EOF

## make sure we have the entrypoints setup correctly
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /
SHELL ["/usr/local/bin/eic-shell"]

## eic-news
COPY --chmod=0755 eic-news /usr/local/bin/eic-news
RUN echo "test -f $HOME/.eic-news && source /usr/local/bin/eic-news" > /etc/profile.d/z13_eic-news.sh 

## Hotfix for misbehaving OSG nodes
RUN mkdir /hadoop
