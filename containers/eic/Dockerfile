#syntax=docker/dockerfile:1.10
#check=error=true
ARG DOCKER_REGISTRY="eicweb/"
ARG BUILDER_IMAGE="debian_stable_base"
ARG RUNTIME_IMAGE="debian_stable_base"
ARG INTERNAL_TAG="master"

##
## This docker build follows three tracks, in order to ensure that we build all packages
## in a builder image, but install them in a runtime image, while at the same time
## avoiding an expensive filesystem copy operation at the end that breaks layering.
##
## The build is split in an infrequently-changing default environment, upon which
## an environment with custom versions (e.g. individual commits) is layered. The
## custom environment will change frequently but layers will be smaller, allowing
## for easier deployment with smaller delta layers.
##
## The separation in a builder and runtime image is particularly relevant to end up with
## lightweight images for expensive build dependencies, such as for example CUDA.
##
## builder track:                        runtime track:
## concretization:     installation:     concretization/installation:
## ---------------------------------------------------------------------------------------
## builder_image                         runtime_image
## builder_concretization_default   
##                \->  builder_installation_default
##                                       runtime_default
##                                       (copy spack.lock from builder_installation_default)
##                                       (install via buildcache)
## \->  builder_concretization_custom
##                     \->  builder_installation_custom
##                                       \->   runtime_custom
##                                             (copy spack.lock from builder_installation_custom)
##                                             (install via buildcache)
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
ARG SPACK_INSTALL_FLAGS="--no-check-signature --show-log-on-error --yes-to-all"
ENV SPACK_COLOR="always"
ENV GIT_TERMINAL_PROMPT=0

# Concretization (default environment)
RUN <<EOF
set -e
spack env activate --without-view --dir ${SPACK_ENV}
spack external find --not-buildable --scope env:${SPACK_ENV} --path /usr/local/cuda/bin cuda
spack external find --scope env:${SPACK_ENV} llvm
spack concretize --force
spack --color=never find --long --no-groups --show-concretized --format "{name}" \
| uniq -D -f2 | grep -v -w -e "\(epic\|llvm\|py-setuptools\|py-urllib3\)" \
| tee /tmp/duplicates.txt
if [ -s /tmp/duplicates.txt ] ; then
  echo "Duplicate packages found"
  cat /tmp/duplicates.txt | while read status hash spec ; do
    spack --backtrace spec --long /${hash}
    if [ "$prevspec" = "$spec" ] ; then
      spack diff /${hash} /${prevhash}
    fi
    prevhash=${hash}
    prevspec=${spec}
  done
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

# Set up GPG key for buildcache signing
# For production use, provide a persistent GPG key via SPACK_SIGNING_KEY secret to ensure
# buildcaches can be verified across builds. Without this secret, a temporary key is created
# for each build, which works for single-build scenarios but prevents buildcache reuse.
RUN --mount=type=secret,id=SPACK_SIGNING_KEY,target=/tmp/spack-signing-key \
    <<EOF
set -e
# Initialize Spack's GPG environment
spack gpg init
# Import signing key if provided, otherwise create a new one
if [ -f /tmp/spack-signing-key ] && [ -s /tmp/spack-signing-key ]; then
  # Import the GPG key (expects ASCII-armored key with both public and private parts)
  # First import into GPG, then Spack will use it from there
  cat /tmp/spack-signing-key | gpg --batch --import
  # Also trust the public key in Spack's keyring for verification
  cat /tmp/spack-signing-key | gpg --batch --export | spack gpg trust
else
  # Create a temporary GPG key for signing (non-interactive)
  # Note: For production, a persistent key should be provided via SPACK_SIGNING_KEY secret
  spack gpg create "EIC Containers" eic-containers@github.com
fi
# List keys to verify setup
spack gpg list
EOF

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
spack clean --downloads --stage
ccache --show-stats
ccache --zero-stats
# Export public key for runtime image verification
spack gpg export > /tmp/spack-public-key.pub
EOF


## ========================================================================================
## runtime_default
## - runtime base with installation of default versions (buildcache populated by builder)
## ========================================================================================
FROM ${DOCKER_REGISTRY}${RUNTIME_IMAGE}:${INTERNAL_TAG} AS runtime_default
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider runtime image (default configuration, $TARGETPLATFORM)"

## Copy our default environment
COPY --from=spack-environment . /opt/spack-environment/
ARG ENV=xl
ENV SPACK_ENV=/opt/spack-environment/${ENV}
ARG SPACK_FLAGS="--backtrace"
ARG SPACK_INSTALL_FLAGS="--show-log-on-error --yes-to-all"
ENV SPACK_COLOR="always"

COPY --from=builder_installation_default \
  /opt/spack-environment/${ENV}/spack.* \
  /opt/spack-environment/${ENV}/
COPY --from=builder_installation_default \
  /tmp/spack-public-key.pub \
  /tmp/spack-public-key.pub

# Import public key for buildcache verification
RUN <<EOF
set -e
spack gpg init
spack gpg trust /tmp/spack-public-key.pub
spack gpg list
EOF

# Installation (default environment, from buildcache)
RUN --mount=type=cache,target=/var/cache/spack                          \
    --mount=type=secret,id=mirrors,target=/opt/spack/etc/spack/mirrors.yaml \
    --mount=type=secret,id=CI_REGISTRY_USER,env=CI_REGISTRY_USER        \
    --mount=type=secret,id=CI_REGISTRY_PASSWORD,env=CI_REGISTRY_PASSWORD \
    --mount=type=secret,id=GITHUB_REGISTRY_USER,env=GITHUB_REGISTRY_USER \
    --mount=type=secret,id=GITHUB_REGISTRY_TOKEN,env=GITHUB_REGISTRY_TOKEN \
    <<EOF
set -e
spack ${SPACK_FLAGS} install ${SPACK_INSTALL_FLAGS} --use-buildcache only
spack gc --yes-to-all go go-bootstrap rust rust-bootstrap py-setuptools-rust py-maturin
EOF


## ========================================================================================
## builder_concretization_custom
## - builder base with concretization of custom versions
## ========================================================================================
FROM builder_concretization_default AS builder_concretization_custom
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider build concretization image (custom configuration, $TARGETPLATFORM)"

# Set spack environment directory
ENV SPACK_ENV=/opt/spack-environment/${ENV}/epic

## 2. Setup our environment with custom versions (on top of cached layer)
## Note: these default versions are just the very first commit.
ARG EDM4EIC_SHA=""
ARG EICRECON_SHA=""
ARG EPIC_SHA=""
ARG JUGGLER_SHA=""

# Concretization (custom environment)
RUN <<EOF
set -e
spack env activate --dir ${SPACK_ENV}
if [ -n "${EDM4EIC_SHA}" ] ; then
  sed -i "/# EDM4EIC_VERSION$/ s/@[^' ]*/@git.${EDM4EIC_SHA}=main/" /opt/spack-environment/packages.yaml
  spack deconcretize -y --all edm4eic
fi
if [ -n "${EICRECON_SHA}" ] ; then
  sed -i "/# EICRECON_VERSION$/ s/@[^' ]*/@git.${EICRECON_SHA}=main/" /opt/spack-environment/packages.yaml
  spack deconcretize -y --all eicrecon
fi
if [ -n "${EPIC_SHA}" ] ; then
  sed -i "/# EPIC_VERSION$/ s/epic\s/epic@git.${EPIC_SHA}=main /" /opt/spack-environment/${ENV}/epic/spack.yaml
  sed -i "/# EPIC_VERSION$/ s/epic@main\s/epic@git.${EPIC_SHA}=main /" /opt/spack-environment/${ENV}/epic/spack.yaml
  spack deconcretize -y --all epic
fi
if [ -n "${JUGGLER_SHA}" ] ; then
  sed -i "/# JUGGLER_VERSION$/ s/@[^' ]*/@git.${JUGGLER_SHA}=main/" /opt/spack-environment/packages.yaml
  spack deconcretize -y --all juggler
fi
spack concretize --force
spack --color=never find --long --no-groups --show-concretized --format "{name}" \
| uniq -D -f2 | grep -v -w -e "\(epic\|llvm\|py-setuptools\|py-urllib3\)" \
| tee /tmp/duplicates.txt
if [ -s /tmp/duplicates.txt ] ; then
  echo "Duplicate packages found"
  cat /tmp/duplicates.txt | while read status hash spec ; do
    spack --backtrace spec --long /${hash}
    if [ "$prevspec" = "$spec" ] ; then
      spack diff /${hash} /${prevhash}
    fi
    prevhash=${hash}
    prevspec=${spec}
  done
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

# Set up GPG key for buildcache signing
# Note: This setup is duplicated from builder_installation_default due to Dockerfile limitations.
# Both builder stages need independent GPG setup as they don't share a common parent with GPG configured.
# For production use, provide a persistent GPG key via SPACK_SIGNING_KEY secret to ensure
# buildcaches can be verified across builds. Without this secret, a temporary key is created
# for each build, which works for single-build scenarios but prevents buildcache reuse.
RUN --mount=type=secret,id=SPACK_SIGNING_KEY,target=/tmp/spack-signing-key \
    <<EOF
set -e
# Initialize Spack's GPG environment
spack gpg init
# Import signing key if provided, otherwise create a new one
if [ -f /tmp/spack-signing-key ] && [ -s /tmp/spack-signing-key ]; then
  # Import the GPG key (expects ASCII-armored key with both public and private parts)
  # First import into GPG, then Spack will use it from there
  cat /tmp/spack-signing-key | gpg --batch --import
  # Also trust the public key in Spack's keyring for verification
  cat /tmp/spack-signing-key | gpg --batch --export | spack gpg trust
else
  # Create a temporary GPG key for signing (non-interactive)
  # Note: For production, a persistent key should be provided via SPACK_SIGNING_KEY secret
  spack gpg create "EIC Containers" eic-containers@github.com
fi
# List keys to verify setup
spack gpg list
EOF

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
spack clean --downloads --stage
spack gc --yes-to-all go go-bootstrap rust rust-bootstrap py-setuptools-rust py-maturin
ccache --show-stats
ccache --zero-stats
# Export public key for runtime image verification
spack gpg export > /tmp/spack-public-key.pub
EOF


## ========================================================================================
## runtime_custom
## - runtime base with installation of custom versions (buildcache populated by builder)
## ========================================================================================
FROM runtime_default AS runtime_custom
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider runtime image (custom configuration, $TARGETPLATFORM)"

# Set spack environment directory
ENV SPACK_ENV=/opt/spack-environment/${ENV}/epic

COPY --from=builder_installation_custom \
  /opt/spack-environment/${ENV}/spack.* \
  /opt/spack-environment/${ENV}/
COPY --from=builder_installation_custom \
  /opt/spack-environment/${ENV}/epic/spack.* \
  /opt/spack-environment/${ENV}/epic/
COPY --from=builder_installation_custom \
  /opt/spack-environment/packages.yaml \
  /opt/spack-environment/
COPY --from=builder_installation_custom \
  /tmp/spack-public-key.pub \
  /tmp/spack-public-key-custom.pub

# Import public key from custom builder for buildcache verification
# Note: This stage is based on runtime_default (FROM runtime_default AS runtime_custom at line 300),
# which already has the public key from builder_installation_default imported.
# However, we also import the key from builder_installation_custom to handle the case
# where temporary keys are used (each builder stage creates a different temporary key).
# With a persistent SPACK_SIGNING_KEY secret, both builders use the same key, making this redundant but harmless.
RUN <<EOF
set -e
spack gpg trust /tmp/spack-public-key-custom.pub
spack gpg list
EOF

# Installation (custom environment, from buildcache)
RUN --mount=type=cache,target=/var/cache/spack                          \
    --mount=type=secret,id=mirrors,target=/opt/spack/etc/spack/mirrors.yaml \
    <<EOF
set -e
spack env activate --dir ${SPACK_ENV}
spack ${SPACK_FLAGS} install ${SPACK_INSTALL_FLAGS} --use-buildcache only
spack gc --yes-to-all go go-bootstrap rust rust-bootstrap py-setuptools-rust py-maturin
EOF


## ========================================================================================
## final image, based on runtime_custom
## ========================================================================================
FROM runtime_custom AS final
ARG TARGETPLATFORM

# Open Container Initiative labels
LABEL org.opencontainers.image.title="Electron-Ion Collider runtime image (custom configuration, $TARGETPLATFORM)"

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

## Fill eic_info
RUN <<EOF
set -e
spack --color=never debug report | sed "s/^/ - /" | sed "s/\* \*\*//" | sed "s/\*\*//" | tee -a /etc/eic_info /etc/jug_info
spack --color=never find --no-groups --long --variants | sed "s/^/ - /" | tee -a /etc/eic_info /etc/jug_info
spack --color=never graph --dot > /opt/spack-environment/env.dot
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
ARG BENCHMARK_COM_SHA=""
ARG BENCHMARK_DET_SHA=""
ARG BENCHMARK_REC_SHA=""
ARG BENCHMARK_PHY_SHA=""
RUN <<EOF
git clone https://eicweb.phy.anl.gov/EIC/benchmarks/common_bench.git /opt/benchmarks/common_bench
git -C /opt/benchmarks/common_bench checkout ${BENCHMARK_COM_SHA:-master}
git clone https://eicweb.phy.anl.gov/EIC/benchmarks/detector_benchmarks.git /opt/benchmarks/detector_benchmarks
git -C /opt/benchmarks/detector_benchmarks checkout ${BENCHMARK_DET_SHA:-master}
ln -sf /opt/benchmarks/common_bench /opt/benchmarks/detector_benchmarks/.local
git clone https://eicweb.phy.anl.gov/EIC/benchmarks/reconstruction_benchmarks.git /opt/benchmarks/reconstruction_benchmarks
git -C /opt/benchmarks/reconstruction_benchmarks checkout ${BENCHMARK_REC_SHA:-master}
ln -sf /opt/benchmarks/common_bench /opt/benchmarks/reconstruction_benchmarks/.local
git clone https://eicweb.phy.anl.gov/EIC/benchmarks/physics_benchmarks.git /opt/benchmarks/physics_benchmarks
git -C /opt/benchmarks/physics_benchmarks checkout ${BENCHMARK_PHY_SHA:-master}
ln -sf /opt/benchmarks/common_bench /opt/benchmarks/physics_benchmarks/.local
EOF

## Install campaigns into the container
ARG CAMPAIGNS_HEPMC3_SHA=""
ARG CAMPAIGNS_CONDOR_SHA=""
ARG CAMPAIGNS_SLURM_SHA=""
RUN <<EOF
git clone https://github.com/eic/simulation_campaign_hepmc3.git /opt/campaigns/hepmc3
git -C /opt/campaigns/hepmc3 checkout ${CAMPAIGNS_HEPMC3_SHA:-main}
git clone https://github.com/eic/job_submission_condor.git /opt/campaigns/condor
git -C /opt/campaigns/condor checkout ${CAMPAIGNS_CONDOR_SHA:-main}
git clone https://github.com/eic/job_submission_slurm.git /opt/campaigns/slurm
git -C /opt/campaigns/slurm checkout ${CAMPAIGNS_SLURM_SHA:-main}
EOF

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

## set the jug_dev version
ARG EIC_CONTAINER_VERSION=1
RUN echo -e "\n - jug_dev: ${EIC_CONTAINER_VERSION}" | tee -a /etc/eic_info /etc/jug_info

## set the eic_container version
ARG CI_COMMIT_SHA
RUN echo -e "\n - eic_container: ${CI_COMMIT_SHA}" | tee -a /etc/eic_info /etc/jug_info

## Hotfix for misbehaving OSG nodes
RUN mkdir /hadoop /localscratch
