#syntax=docker/dockerfile:1.10
#check=error=true
ARG DOCKER_REGISTRY="eicweb/"
ARG BUILDER_IMAGE="debian_stable_base"
ARG RUNTIME_IMAGE="debian_stable_base"
ARG INTERNAL_TAG="master"

##
## This docker build follows two tracks, in order to ensure that we build all packages
## in a builder image, but install them in a runtime image, while at the same time
## avoiding a expensive filesystem copy operation at the end that breaks layering.
##
## The build is split in an infrequently-changing default environment, upon which
## an environment with custom versions (e.g. individual commits) is layered. The
## custom environment will change frequently but layers will be smaller, allowing
## for easier deployment with smaller delta layers.
##
## The separation in a builder and runtime image is particularly relevant to end up with
## lightweight images for expensive build dependencies, such as for example CUDA.
##
## builder track                         runtime track
## ----------------------------------------------------------------------
## builder_image                         runtime_image
## builder_concretization_default   
## builder_installation_default     ->   runtime_concretization_default  (copy spack.lock)
##                                 \->   runtime_installation_default    (from buildcache)
## builder_concretization_custom
## builder_installation_custom      ->   runtime_concretization_custom   (copy spack.lock)
##                                 \->   runtime_installation_custom     (from buildcache)
##


## ========================================================================================
## builder_concretization_default
## - builder base with concretization of default versions
## ========================================================================================
FROM ${DOCKER_REGISTRY}${BUILDER_IMAGE}:${INTERNAL_TAG} AS builder_concretization_default
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider build concretization image (default configuration, $TARGETPLATFORM)"

## Copy our default environment
COPY --from=spack-environment . /opt/spack-environment/
ARG ENV=xl
ENV SPACK_ENV=/opt/spack-environment/${ENV}
ARG SPACK_FLAGS="--backtrace"
ARG SPACK_INSTALL_FLAGS="--no-check-signature --show-log-on-error --yes-to-all --verbose"
ENV SPACK_COLOR="always"

# Concretization (default environment)
RUN <<EOF
spack env activate --without-view --dir ${SPACK_ENV}
spack external find --not-buildable --scope env:${SPACK_ENV} --path /usr/local/cuda/bin cuda
spack external find --not-buildable --scope env:${SPACK_ENV} llvm
spack concretize --force
spack --color=never find --long --no-groups --show-concretized --format "{name}" \
| uniq -D -f2 | grep -v -w -e "\(epic\|py-pip\|py-cython\|py-setuptools\)" \
| tee /tmp/duplicates.txt
if [ -s /tmp/duplicates.txt ] ; then
  echo "Duplicate packages found"
  cat /tmp/duplicates.txt | while read status hash spec ; do echo "'/${hash}'" ; spack --backtrace spec --long /${hash} ; done
  exit 1
fi
EOF


## ========================================================================================
## builder_installation_default
## - builder base with installation of default versions
## ========================================================================================
FROM builder_concretization_default AS builder_installation_default
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider build installation image (default configuration, $TARGETPLATFORM)"

# Installation (default environment)
RUN --mount=type=cache,target=/ccache,id=ccache-${TARGETPLATFORM}              \
    --mount=type=cache,target=/var/cache/spack                          \
    --mount=type=secret,id=mirrors,target=/opt/spack/etc/spack/mirrors.yaml \
    --mount=type=secret,id=CI_REGISTRY_USER,env=CI_REGISTRY_USER        \
    --mount=type=secret,id=CI_REGISTRY_PASSWORD,env=CI_REGISTRY_PASSWORD \
    --mount=type=secret,id=GITHUB_REGISTRY_USER,env=GITHUB_REGISTRY_USER \
    --mount=type=secret,id=GITHUB_REGISTRY_TOKEN,env=GITHUB_REGISTRY_TOKEN \
    <<EOF
set -e
export CCACHE_DIR=/ccache
mkdir -p /var/cache/spack/blobs/sha256/
find /var/cache/spack/blobs/sha256/ -ignore_readdir_race -atime +7 -delete
spack ${SPACK_FLAGS} install ${SPACK_INSTALL_FLAGS}
ccache --show-stats
ccache --zero-stats
EOF


## ========================================================================================
## runtime_concretization_default
## - runtime base with concretization of default versions (taken from equivalent builder)
## ========================================================================================
FROM ${DOCKER_REGISTRY}${RUNTIME_IMAGE}:${INTERNAL_TAG} AS runtime_concretization_default
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider runtime concretization image (default configuration, $TARGETPLATFORM)"

## Copy our default environment
COPY --from=spack-environment . /opt/spack-environment/
ARG ENV=xl
ENV SPACK_ENV=/opt/spack-environment/${ENV}
ARG SPACK_FLAGS="--backtrace"
ARG SPACK_INSTALL_FLAGS="--no-check-signature --show-log-on-error --yes-to-all --verbose"
ENV SPACK_COLOR="always"

COPY --from=builder_installation_default \
  /opt/spack-environment/${ENV}/spack.* \
  /opt/spack-environment/${ENV}/


## ========================================================================================
## runtime_installation_default
## - runtime base with installation of default versions (buildcache populated by builder)
## ========================================================================================
FROM runtime_concretization_default AS runtime_installation_default
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider runtime installation image (default configuration, $TARGETPLATFORM)"

# Installation (default environment, from buildcache)
RUN --mount=type=cache,target=/var/cache/spack                          \
    --mount=type=secret,id=mirrors,target=/opt/spack/etc/spack/mirrors.yaml \
    --mount=type=secret,id=CI_REGISTRY_USER,env=CI_REGISTRY_USER        \
    --mount=type=secret,id=CI_REGISTRY_PASSWORD,env=CI_REGISTRY_PASSWORD \
    --mount=type=secret,id=GITHUB_REGISTRY_USER,env=GITHUB_REGISTRY_USER \
    --mount=type=secret,id=GITHUB_REGISTRY_TOKEN,env=GITHUB_REGISTRY_TOKEN \
    <<EOF
spack ${SPACK_FLAGS} install ${SPACK_INSTALL_FLAGS} --use-buildcache only
spack gc --yes-to-all
EOF


## ========================================================================================
## builder_concretization_custom
## - builder base with concretization of custom versions
## ========================================================================================
FROM builder_installation_default AS builder_concretization_custom
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider build concretization image (custom configuration, $TARGETPLATFORM)"

## 2. Setup our environment with custom versions (on top of cached layer)
## Note: these default versions are just the very first commit.
ARG EDM4EIC_VERSION="8aeb507f93a93257c99985efbce0ec1371e0b331"
ARG EICRECON_VERSION="28108da4a1e8919a05dfdb5f11e114800a2cbe96"
ARG EPIC_VERSION="c1827f05430b2051df8a0b421db1cbab87165e0b"
ARG JUGGLER_VERSION="df87bf1f8643afa8e80bece9d36d6dc26dfe8132"
ADD https://api.github.com/repos/eic/edm4eic/commits/${EDM4EIC_VERSION} /tmp/edm4eic.json
ADD https://api.github.com/repos/eic/eicrecon/commits/${EICRECON_VERSION} /tmp/eicrecon.json
ADD https://api.github.com/repos/eic/epic/commits/${EPIC_VERSION} /tmp/epic.json
ADD https://api.github.com/repos/eic/juggler/commits/${JUGGLER_VERSION} /tmp/juggler.json

# Concretization (custom environment)
RUN <<EOF
spack env activate --dir ${SPACK_ENV}
if [ "${EDM4EIC_VERSION}" != "8aeb507f93a93257c99985efbce0ec1371e0b331" ] ; then
  export EDM4EIC_VERSION=$(jq -r .sha /tmp/edm4eic.json)
  sed -i "/# EDM4EIC_VERSION$/ s/@[^' ]*/@git.${EDM4EIC_VERSION}=main/" /opt/spack-environment/packages.yaml
  spack deconcretize -y --all edm4eic
fi
if [ "${EICRECON_VERSION}" != "28108da4a1e8919a05dfdb5f11e114800a2cbe96" ] ; then
  export EICRECON_VERSION=$(jq -r .sha /tmp/eicrecon.json)
  sed -i "/# EICRECON_VERSION$/ s/@[^' ]*/@git.${EICRECON_VERSION}=main/" /opt/spack-environment/packages.yaml
  spack deconcretize -y --all eicrecon
fi
if [ "${EPIC_VERSION}" != "c1827f05430b2051df8a0b421db1cbab87165e0b" ] ; then
  export EPIC_VERSION=$(jq -r .sha /tmp/epic.json)
  sed -i "/# EPIC_VERSION$/ s/epic\s/epic@git.${EPIC_VERSION}=main /" /opt/spack-environment/${ENV}/spack.yaml
  sed -i "/# EPIC_VERSION$/ s/epic@main\s/epic@git.${EPIC_VERSION}=main /" /opt/spack-environment/${ENV}/spack.yaml
  spack deconcretize -y --all epic
fi
if [ "${JUGGLER_VERSION}" != "df87bf1f8643afa8e80bece9d36d6dc26dfe8132" ] ; then
  export JUGGLER_VERSION=$(jq -r .sha /tmp/juggler.json)
  sed -i "/# JUGGLER_VERSION$/ s/@[^' ]*/@git.${JUGGLER_VERSION}=main/" /opt/spack-environment/packages.yaml
  spack deconcretize -y --all juggler
fi
spack concretize --force
spack --color=never find --long --no-groups --show-concretized --format "{name}" \
| uniq -D -f2 | grep -v -w -e "\(epic\|py-pip\|py-cython\|py-setuptools\)" \
| tee /tmp/duplicates.txt
if [ -s /tmp/duplicates.txt ] ; then
  echo "Duplicate packages found"
  cat /tmp/duplicates.txt | while read status hash spec ; do echo "'/${hash}'" ; spack --backtrace spec --long /${hash} ; done
  exit 1
fi
EOF


## ========================================================================================
## builder_installation_custom
## - builder base with installation of custom versions
## ========================================================================================
FROM builder_concretization_custom AS builder_installation_custom
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider build installation image (custom configuration, $TARGETPLATFORM)"

# Installation (custom environment)
RUN --mount=type=cache,target=/ccache,id=ccache-${TARGETPLATFORM}              \
    --mount=type=cache,target=/var/cache/spack                          \
    --mount=type=secret,id=mirrors,target=/opt/spack/etc/spack/mirrors.yaml \
    --mount=type=secret,id=CI_REGISTRY_USER,env=CI_REGISTRY_USER        \
    --mount=type=secret,id=CI_REGISTRY_PASSWORD,env=CI_REGISTRY_PASSWORD \
    --mount=type=secret,id=GITHUB_REGISTRY_USER,env=GITHUB_REGISTRY_USER \
    --mount=type=secret,id=GITHUB_REGISTRY_TOKEN,env=GITHUB_REGISTRY_TOKEN \
    <<EOF
set -e
export CCACHE_DIR=/ccache
spack ${SPACK_FLAGS} install ${SPACK_INSTALL_FLAGS}

spack gc --yes-to-all
ccache --show-stats
ccache --zero-stats
EOF


## ========================================================================================
## runtime_concretization_custom
## - runtime base with concretization of custom versions (taken from equivalent builder)
## ========================================================================================
FROM runtime_installation_default AS runtime_concretization_custom
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider runtime concretization image (custom configuration, $TARGETPLATFORM)"

COPY --from=builder_installation_custom \
  /opt/spack-environment/${ENV}/spack.* \
  /opt/spack-environment/${ENV}/
COPY --from=builder_installation_custom \
  /opt/spack-environment/packages.yaml \
  /opt/spack-environment/


## ========================================================================================
## runtime_installation_custom
## - runtime base with installation of custom versions (buildcache populated by builder)
## ========================================================================================
FROM runtime_concretization_custom AS runtime_installation_custom
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider runtime installation image (custom configuration, $TARGETPLATFORM)"

# Installation (default environment, from buildcache)
RUN --mount=type=cache,target=/var/cache/spack                          \
    --mount=type=secret,id=mirrors,target=/opt/spack/etc/spack/mirrors.yaml \
    <<EOF
set -e
spack ${SPACK_FLAGS} install ${SPACK_INSTALL_FLAGS} --use-buildcache only
spack gc --yes-to-all
EOF


## ========================================================================================
## final image, based on runtime_installation_custom
## ========================================================================================
FROM runtime_installation_custom
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider runtime installation image (custom configuration, $TARGETPLATFORM)"

## Ensure views directories, not symlinks
RUN <<EOF
set -e
rm -rf /opt/local /opt/detector
LOCAL_PREFIX_PATH=$(realpath $(ls /opt/._local/ | tail -n1))
mv /opt/._local/${LOCAL_PREFIX_PATH} /opt/local
ln -s /opt/local /opt/._local/${LOCAL_PREFIX_PATH}
DETECTOR_PREFIX_PATH=$(realpath $(ls /opt/._detector/ | tail -n1))
mv /opt/._detector/${DETECTOR_PREFIX_PATH} /opt/detector
ln -s /opt/detector /opt/._detector/${DETECTOR_PREFIX_PATH}
EOF

## Place cvmfs catalogs
RUN <<EOF
set -e
touch ${SPACK_ROOT}/.cvmfscatalog
touch /opt/software/.cvmfscatalog
find /opt/software -mindepth 2 -maxdepth 3 -type d -exec touch {}/.cvmfscatalog \;
touch /opt/local/.cvmfscatalog
EOF

## Store environment
RUN <<EOF
set -e
spack env activate --sh --dir ${SPACK_ENV} > /etc/profile.d/z10_spack_environment.sh
EOF

## Fixup /opt/detector/epic-git.fcf90937193c983c0af2acf1251e01f2e2c3a259_main
RUN <<EOF
set -e
shopt -s nullglob
cd /opt/detector
for detector in epic-git.*_* ; do
  ln -s ${detector} epic-${detector/*_/}
done
EOF

## Fill jug_info
RUN <<EOF
set -e
spack debug report | sed "s/^/ - /" | sed "s/\* \*\*//" | sed "s/\*\*//" >> /etc/jug_info
spack find --no-groups --long --variants | sed "s/^/ - /" >> /etc/jug_info
spack graph --dot > /opt/spack-environment/env.dot
EOF

## Copy custom content
COPY eic-shell /opt/local/bin/eic-shell
COPY eic-info /opt/local/bin/eic-info
COPY entrypoint.sh /opt/local/sbin/entrypoint.sh
COPY eic-env.sh /etc/eic-env.sh
COPY profile.d/* /etc/profile.d
COPY singularity.d /.singularity.d

## set ROOT TFile forward compatibility
RUN sed --in-place --follow-symlinks 's/# \(TFile.v630forwardCompatibility:\) no/\1 yes/' /opt/local/etc/root/system.rootrc

## Setup ld.so.conf with what could go in LD_LIBRARY_PATH (but lower priority)
## Ref: https://man7.org/linux/man-pages/man8/ld.so.8.html
COPY <<EOF /etc/ld.so.conf.d/eic-shell.conf
/opt/local/lib/root
EOF
RUN ldconfig

## set the local spack configuration
ENV SPACK_DISABLE_LOCAL_CONFIG="true"
RUN <<EOF
set -e
spack config --scope site add "config:install_tree:root:~/spack"
spack config --scope site add "config:source_cache:~/.spack/cache"
spack config --scope site add "config:binary_index_root:~/.spack"
spack config --scope site add "config:environments_root:~/.spack/env"
spack config --scope site add "config:suppress_gpg_warnings:true"
spack config blame config
spack config --scope site add "upstreams:eic-shell:install_tree:/opt/software"
spack config blame upstreams
EOF

## Install benchmarks into the container
ARG BENCHMARK_COM_VERSION="master"
ARG BENCHMARK_DET_VERSION="master"
ARG BENCHMARK_REC_VERSION="master"
ARG BENCHMARK_PHY_VERSION="master"
ADD https://eicweb.phy.anl.gov/EIC/benchmarks/common_bench.git#${BENCHMARK_COM_VERSION} /opt/benchmarks/common_bench
ADD https://eicweb.phy.anl.gov/EIC/benchmarks/detector_benchmarks.git#${BENCHMARK_DET_VERSION} /opt/benchmarks/detector_benchmarks
ADD https://eicweb.phy.anl.gov/EIC/benchmarks/reconstruction_benchmarks.git#${BENCHMARK_REC_VERSION} /opt/benchmarks/reconstruction_benchmarks
ADD https://eicweb.phy.anl.gov/EIC/benchmarks/physics_benchmarks.git#${BENCHMARK_PHY_VERSION} /opt/benchmarks/physics_benchmarks
RUN <<EOF
ln -sf ../common_bench /opt/benchmarks/detector_benchmarks/.local
ln -sf ../common_bench /opt/benchmarks/reconstruction_benchmarks/.local
ln -sf ../common_bench /opt/benchmarks/physics_benchmarks/.local
EOF

## Install campaigns into the container
ARG CAMPAIGNS_HEPMC3_VERSION="main"
ARG CAMPAIGNS_CONDOR_VERSION="main"
ARG CAMPAIGNS_SLURM_VERSION="main"
ADD https://github.com/eic/simulation_campaign_hepmc3.git#${CAMPAIGNS_HEPMC3_VERSION} /opt/campaigns/hepmc3
ADD https://github.com/eic/job_submission_condor.git#${CAMPAIGNS_CONDOR_VERSION} /opt/campaigns/condor
ADD https://github.com/eic/job_submission_slurm.git#${CAMPAIGNS_SLURM_VERSION} /opt/campaigns/slurm

## make sure we have the entrypoints setup correctly
ENTRYPOINT ["/opt/local/sbin/entrypoint.sh"]
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /
SHELL ["/opt/local/bin/eic-shell"]

## rucio config (unprivileged read-only account)
COPY <<EOF /opt/rucio/etc/rucio.cfg
[client]
rucio_host = https://rucio-server.jlab.org:443
auth_host = https://rucio-server.jlab.org:443
auth_type = userpass
username = eicread
password = eicread

[policy]
package = eic_rucio_policy_package
extract_scope = eic
lfn2pfn_algorithm_default = eic
EOF

## eic-news
COPY --chmod=0755 eic-news /opt/local/bin/eic-news

## set the container version
ARG EIC_CONTAINER_VERSION=1
RUN echo -e "\n - jug_dev: ${EIC_CONTAINER_VERSION}" >> /etc/jug_info

## Hotfix for misbehaving OSG nodes
RUN mkdir /hadoop /localscratch
