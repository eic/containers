#syntax=docker/dockerfile:1.8
#check=error=true
ARG BASE_IMAGE="amd64/debian:stable-slim"
ARG BUILD_IMAGE="debian_stable_base"

# Minimal container based on Debian base systems for up-to-date packages. 
FROM ${BASE_IMAGE}
ARG TARGETPLATFORM

# Open Container Initiative labels (no heredoc support)
LABEL \
org.opencontainers.image.vendor="Electron-Ion Collider" \
org.opencontainers.image.authors="Electron-Ion Collider Software Working Groups <eic-software-l-owner@lists.bnl.gov>" \
org.opencontainers.image.url="https://github.com/eic/containers" \
org.opencontainers.image.source="https://github.com/eic/containers" \
org.opencontainers.image.documentation="https://eic.github.io" \
org.opencontainers.image.license="GPL-3.0-or-later"
LABEL org.opencontainers.image.title="Electron-Ion Collider base image ($TARGETPLATFORM)"

COPY bashrc /root/.bashrc

## With heredocs for multi-line scripts, we want to fail on error and the print failing line.
## Ref: https://docs.docker.com/engine/reference/builder/#example-running-a-multi-line-script
SHELL ["bash", "-ex", "-c"]

ENV CLICOLOR_FORCE=1                                                    \
    DEBIAN_FRONTEND=noninteractive                                      \
    LANGUAGE=en_US.UTF-8                                                \
    LANG=en_US.UTF-8                                                    \
    LC_ALL=en_US.UTF-8

## Install additional packages. Remove the auto-cleanup functionality
## for docker, as we're using the new buildkit cache instead.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked <<EOF
rm -f /etc/apt/apt.conf.d/docker-clean
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
echo "US/Eastern" > /etc/timezone
apt-get -yqq update
apt-get -yqq install --no-install-recommends                            \
        bc                                                              \
        bzip2                                                           \
        ca-certificates                                                 \
        ccache                                                          \
        curl                                                            \
        file                                                            \
        gawk                                                            \
        gdb                                                             \
        git                                                             \
        gnupg2                                                          \
        iproute2                                                        \
        iputils-ping                                                    \
        iputils-tracepath                                               \
        less                                                            \
        libc6-dbg                                                       \
        libegl-dev                                                      \
        libgl-dev                                                       \
        libglew-dev                                                     \
        libglx-dev                                                      \
        libopengl-dev                                                   \
        locales                                                         \
        make                                                            \
        moreutils                                                       \
        nano                                                            \
        openssh-client                                                  \
        parallel                                                        \
        patch                                                           \
        time                                                            \
        unzip                                                           \
        vim-nox                                                         \
        wget
apt-get -yqq autoremove
localedef -i en_US -f UTF-8 en_US.UTF-8
EOF

# Install updated compilers, with support for multiple base images
## Ubuntu: latest gcc from toolchain ppa, latest stable clang
## Debian: default gcc with distribution, latest stable clang
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked <<EOF
. /etc/os-release
mkdir -p /etc/apt/source.list.d
# GCC and CLANG version and repository
case ${ID} in
  debian)
    case ${VERSION_CODENAME} in
      bookworm) GCC="-12" ; CLANG="-18" ;;
      trixie) GCC="-14" ; CLANG="-19" ;;
      *) echo "Unsupported VERSION_CODENAME=${VERSION_CODENAME}" ; exit 1 ;;
    esac ;;
  ubuntu)
    echo "deb http://ppa.launchpad.net/ubuntu-toolchain-r/ppa/ubuntu/${VERSION_CODENAME} main" > /etc/apt/source.list.d/ubuntu-toolchain.list
    case ${VERSION_CODENAME} in
      focal) GCC="-10" ; CLANG="-16" ;;
      jammy) GCC="-12" ; CLANG="-16" ;;
      noble) GCC="-13" ; CLANG="-17" ;;
      *) echo "Unsupported VERSION_CODENAME=${VERSION_CODENAME}" ; exit 1 ;;
    esac ;;
  *) echo "Unsupported ID=${ID}" ; exit 1 ;;
esac
# Clang repository
curl -s https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
if [ ${VERSION_CODENAME} = trixie ] ; then
  echo "deb http://apt.llvm.org/unstable llvm-toolchain${CLANG} main" > /etc/apt/sources.list.d/llvm.list
else
  echo "deb http://apt.llvm.org/${VERSION_CODENAME} llvm-toolchain-${VERSION_CODENAME}${CLANG} main" > /etc/apt/sources.list.d/llvm.list
fi
# Install packages
apt-get -yqq update
apt-get -yqq install cpp${GCC} gcc${GCC} g++${GCC} gfortran${GCC}
apt-get -yqq install clang${CLANG} clang-tidy${CLANG} clang-format${CLANG} libclang${CLANG}-dev libc++${CLANG}-dev
apt-get -yqq autoremove
# Remove symlinks loop in nvidia/cuda:12.5.1-devel-ubuntu24.04
rm -f /usr/bin/cpp /etc/alternatives/cpp
# Ensure alternatives without version tags
update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp${GCC} 100
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc${GCC} 100
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++${GCC} 100
update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran${GCC} 100
update-alternatives --install /usr/bin/clang clang /usr/bin/clang${CLANG} 100
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++${CLANG} 100
update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format${CLANG} 100
update-alternatives --install /usr/bin/clang-format-diff clang-format-diff /usr/bin/clang-format-diff${CLANG} 100
update-alternatives --install /usr/bin/clang-tidy-diff clang-tidy-diff /usr/bin/clang-tidy-diff${CLANG}.py 100
update-alternatives --install /usr/bin/run-clang-tidy run-clang-tidy /usr/bin/run-clang-tidy${CLANG}.py 100
update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config${CLANG} 100
# Default to gcc
update-alternatives --install /usr/bin/cc  cc  /usr/bin/gcc 100
update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 100
# Check versions
gcc --version
clang --version
EOF

## Install some extra spack dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-${TARGETPLATFORM} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=apt-lists-${TARGETPLATFORM} <<EOF
rm -f /etc/apt/apt.conf.d/docker-clean
apt-get -yqq update
apt-get -yqq install --no-install-recommends                            \
        jq                                                              \
        python3                                                         \
        python3-dev                                                     \
        python-is-python3
EOF

## Setup git
RUN <<EOF
git config --global user.email "gitlab@eicweb.phy.anl.gov"
git config --global user.name "EIC Container Build Service"
git config --global advice.detachedHead false
git config --global gc.autoDetach false
git config --global merge.directoryRenames true
EOF

## Setup spack
ENV SPACK_ROOT=/opt/spack
ARG SPACK_ORGREPO="spack/spack"
ARG SPACK_VERSION="develop"
ENV SPACK_PYTHON=/usr/bin/python3
ARG SPACK_CHERRYPICKS=""
ARG SPACK_CHERRYPICKS_FILES=""
# Dockerfile ADD --keep-git-dir clones a shallow copy preventing cherry-picking
#ADD --keep-git-dir https://github.com/${SPACK_ORGREPO}.git#${SPACK_VERSION} ${SPACK_ROOT}
# so we git clone the default branch and checkout the specific commit
RUN <<EOF
set -e
git clone --filter=tree:0 https://github.com/${SPACK_ORGREPO}.git ${SPACK_ROOT}
git -C ${SPACK_ROOT} checkout ${SPACK_VERSION}
if [ -n "${SPACK_CHERRYPICKS}" ] ; then
  SPACK_CHERRYPICKS="${SPACK_CHERRYPICKS// /$'\n'}"
  SPACK_CHERRYPICKS_FILES="${SPACK_CHERRYPICKS_FILES// /$'\n'}"
  SPACK_CHERRYPICKS=$(git -C ${SPACK_ROOT} rev-list --topo-order ${SPACK_CHERRYPICKS} | grep -m $(echo "${SPACK_CHERRYPICKS}" | wc -l)  "${SPACK_CHERRYPICKS}" | tac)
  eval "declare -A SPACK_CHERRYPICKS_FILES_ARRAY=(${SPACK_CHERRYPICKS_FILES})"
  for hash in ${SPACK_CHERRYPICKS} ; do
    if [ -n "${SPACK_CHERRYPICKS_FILES_ARRAY[${hash}]+found}" ] ; then
      git -C ${SPACK_ROOT} show ${hash} -- ${SPACK_CHERRYPICKS_FILES_ARRAY[${hash}]//,/ } | patch -p1 -d ${SPACK_ROOT}
      git -C ${SPACK_ROOT} commit --all --message "$(git -C ${SPACK_ROOT} show --no-patch --pretty=format:%s ${hash})"
    else
      git -C ${SPACK_ROOT} cherry-pick ${hash}
    fi
  done
fi
git -C ${SPACK_ROOT} gc --prune=all --aggressive
sed -i 's/timeout=60/timeout=None/' ${SPACK_ROOT}/lib/spack/spack/stage.py
ln -s ${SPACK_ROOT}/share/spack/docker/entrypoint.bash /usr/bin/docker-shell
ln -s ${SPACK_ROOT}/share/spack/docker/entrypoint.bash /usr/bin/interactive-shell
ln -s ${SPACK_ROOT}/share/spack/docker/entrypoint.bash /usr/bin/spack-env
EOF

## Use spack entrypoint. NOTE: Requires `set -ex` in all multi-line scripts!
SHELL ["docker-shell"]

## Setup spack-packages
ENV SPACKPACKAGES_ROOT=/opt/spack-packages
ARG SPACKPACKAGES_ORGREPO="spack/spack-packages"
ARG SPACKPACKAGES_VERSION="develop"
ARG SPACKPACKAGES_CHERRYPICKS=""
ARG SPACKPACKAGES_CHERRYPICKS_FILES=""
# Dockerfile ADD --keep-git-dir clones a shallow copy preventing cherry-picking
#ADD --keep-git-dir https://github.com/${SPACKPACKAGES_ORGREPO}.git#${SPACKPACKAGES_VERSION} ${SPACKPACKAGES_ROOT}
# so we git clone the default branch and checkout the specific commit
RUN <<EOF
set -e
git clone --filter=tree:0 https://github.com/${SPACKPACKAGES_ORGREPO}.git ${SPACKPACKAGES_ROOT}
git -C ${SPACKPACKAGES_ROOT} checkout ${SPACKPACKAGES_VERSION}
if [ -n "${SPACKPACKAGES_CHERRYPICKS}" ] ; then
  SPACKPACKAGES_CHERRYPICKS="${SPACKPACKAGES_CHERRYPICKS// /$'\n'}"
  SPACKPACKAGES_CHERRYPICKS_FILES="${SPACKPACKAGES_CHERRYPICKS_FILES// /$'\n'}"
  SPACKPACKAGES_CHERRYPICKS=$(git -C ${SPACKPACKAGES_ROOT} rev-list --topo-order ${SPACKPACKAGES_CHERRYPICKS} | grep -m $(echo "${SPACKPACKAGES_CHERRYPICKS}" | wc -l)  "${SPACKPACKAGES_CHERRYPICKS}" | tac)
  eval "declare -A SPACKPACKAGES_CHERRYPICKS_FILES_ARRAY=(${SPACKPACKAGES_CHERRYPICKS_FILES})"
  for hash in ${SPACKPACKAGES_CHERRYPICKS} ; do
    if [ -n "${SPACKPACKAGES_CHERRYPICKS_FILES_ARRAY[${hash}]+found}" ] ; then
      git -C ${SPACKPACKAGES_ROOT} show ${hash} -- ${SPACKPACKAGES_CHERRYPICKS_FILES_ARRAY[${hash}]//,/ } | patch -p1 -d ${SPACKPACKAGES_ROOT}
      git -C ${SPACKPACKAGES_ROOT} commit --all --message "$(git -C ${SPACKPACKAGES_ROOT} show --no-patch --pretty=format:%s ${hash})"
    else
      git -C ${SPACKPACKAGES_ROOT} cherry-pick ${hash}
    fi
  done
fi
git -C ${SPACKPACKAGES_ROOT} gc --prune=all --aggressive
spack repo add --scope site "${SPACKPACKAGES_ROOT}/repos/spack_repo/builtin"
EOF

## Setup build configuration
ARG jobs=1
RUN <<EOF
set -e
declare -A target=(
  ["linux/amd64"]="x86_64_v2"
  ["linux/amd64/v2"]="x86_64_v2"
  ["linux/amd64/v3"]="x86_64_v3"
  ["linux/amd64/v4"]="x86_64_v4"
  ["linux/arm64"]="aarch64"
)
target=${target[${TARGETPLATFORM}]}
spack config --scope site add "packages:all:require:[target=${target}]"
spack config --scope site add "packages:all:target:[${target}]"
spack config blame packages
mkdir -p $HOME/.spack/
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

## Setup buildcache mirrors
## - this always adds the read-only mirror to the container
## - the write-enabled mirror is provided later as a secret mount
RUN --mount=type=cache,target=/var/cache/spack <<EOF
set -e
spack mirror add --scope site --signed spack-${SPACK_VERSION} https://binaries.spack.io/${SPACK_VERSION}
spack mirror add --scope site --unsigned ghcr-${SPACK_VERSION} oci://ghcr.io/eic/spack-${SPACK_VERSION}
spack mirror list
EOF

## Setup key4hep-spack (no need for cherry-picks)
ENV KEY4HEPSPACK_ROOT=${SPACKPACKAGES_ROOT}/repos/key4hep-spack
ARG KEY4HEPSPACK_ORGREPO="key4hep/key4hep-spack"
ARG KEY4HEPSPACK_VERSION="main"
RUN <<EOF
set -e
git clone --filter=tree:0 https://github.com/${KEY4HEPSPACK_ORGREPO}.git ${KEY4HEPSPACK_ROOT}
git -C ${KEY4HEPSPACK_ROOT} checkout ${KEY4HEPSPACK_VERSION}
spack repo add --scope site "${KEY4HEPSPACK_ROOT}"
EOF

## Setup eic-spack (no need for cherry-picks)
ENV EICSPACK_ROOT=${SPACKPACKAGES_ROOT}/repos/eic-spack
ARG EICSPACK_ORGREPO="eic/eic-spack"
ARG EICSPACK_VERSION="develop"
RUN <<EOF
set -e
git clone --filter=tree:0 https://github.com/${EICSPACK_ORGREPO}.git ${EICSPACK_ROOT}
git -C ${EICSPACK_ROOT} checkout ${EICSPACK_VERSION}
spack repo add --scope site "${EICSPACK_ROOT}"
EOF
