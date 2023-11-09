#syntax=docker/dockerfile:1.4
ARG BASE_IMAGE="amd64/debian:stable-slim"
ARG BUILD_IMAGE="debian_stable_base"

# Minimal container based on Debian base systems for up-to-date packages. 
FROM  ${BASE_IMAGE}
LABEL maintainer="Sylvester Joosten <sjoosten@anl.gov>" \
      name="${BUILD_IMAGE}" \
      march="amd64"

COPY bashrc /root/.bashrc

## With heredocs for multi-line scripts, we want to fail on error and the print failing line.
## Ref: https://docs.docker.com/engine/reference/builder/#example-running-a-multi-line-script
SHELL ["bash", "-ex", "-c"]

ENV CLICOLOR_FORCE=1                                                    \
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
        gdb                                                             \
        ghostscript                                                     \
        git                                                             \
        gnupg2                                                          \
        gv                                                              \
        iproute2                                                        \
        iputils-ping                                                    \
        iputils-tracepath                                               \
        less                                                            \
        libcbor-xs-perl                                                 \
        libjson-xs-perl                                                 \
        libopengl-dev                                                   \
        libglx-dev                                                      \
        locales                                                         \
        lua-posix                                                       \
        make                                                            \
        moreutils                                                       \
        nano                                                            \
        openssh-client                                                  \
        parallel                                                        \
        patch                                                           \
        poppler-utils                                                   \
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
if [ "${ID}" = "ubuntu" ] ; then
  echo "deb http://ppa.launchpad.net/ubuntu-toolchain-r/ppa/ubuntu/${VERSION_CODENAME} main" > /etc/apt/source.list.d/ubuntu-toolchain.list
  if [ "${VERSION_ID}" = "20.04" ] ; then GCC="-10" CLANG="-12" ; fi
  if [ "${VERSION_ID}" = "22.04" ] ; then GCC="-12" CLANG="-14" ; fi
  curl -s https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
  echo "deb http://apt.llvm.org/${VERSION_CODENAME} llvm-toolchain-${VERSION_CODENAME}${CLANG} main" > /etc/apt/source.list.d/llvm.list
  apt-get -yqq update
  apt-get -yqq install gcc${GCC} g++${GCC} gfortran${GCC}
  apt-get -yqq install clang${CLANG} clang-tidy${CLANG} clang-format${CLANG}
  apt-get -yqq install iwyu
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc${GCC} 100
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++${GCC} 100
  update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran${GCC} 100
  update-alternatives --install /usr/bin/clang clang /usr/bin/clang${CLANG} 100
  update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++${CLANG} 100
else
  apt-get -yqq update
  apt-get -yqq install gcc g++ gfortran
  apt-get -yqq install clang clang-tidy clang-format
  apt-get -yqq install iwyu
fi
apt-get -yqq autoremove
gcc --version
clang --version
EOF
