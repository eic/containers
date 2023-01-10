#syntax=docker/dockerfile:1.2
ARG DOCKER_REGISTRY="eicweb.phy.anl.gov:4567/containers/eic_container/"
ARG BASE_IMAGE="debian_base"
ARG INTERNAL_TAG="testing"

## ========================================================================================
## STAGE1: spack builder image
## EIC builder image with spack
## ========================================================================================
FROM ${DOCKER_REGISTRY}${BASE_IMAGE}:${INTERNAL_TAG} as builder

## install some extra spack dependencies
RUN --mount=type=cache,target=/var/cache/apt                            \
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
## parts:
ARG ARCH="x86_64"
ENV SPACK_ROOT=/opt/spack
ARG SPACK_ORGREPO="spack/spack"
ARG SPACK_VERSION="develop"
ARG SPACK_CHERRYPICKS=""
ADD https://api.github.com/repos/${SPACK_ORGREPO}/commits/${SPACK_VERSION} /tmp/spack.json
RUN git clone https://github.com/${SPACK_ORGREPO}.git ${SPACK_ROOT}     \
 && git -C ${SPACK_ROOT} checkout ${SPACK_VERSION}                      \
 && if [ -n "$SPACK_CHERRYPICKS" ] ; then                               \
      git -C ${SPACK_ROOT} cherry-pick -n $SPACK_CHERRYPICKS ;          \
    fi                                                                  \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash                \
          /usr/sbin/docker-shell                                        \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash                \
          /usr/sbin/interactive-shell                                   \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash                \
          /usr/sbin/spack-env                                           \
 && export PATH=${PATH}:${SPACK_ROOT}/bin                               \
 && spack config --scope site add "packages:all:require:arch=${ARCH}"   \
 && spack config blame packages                                         \
 && spack config --scope site add "config:suppress_gpg_warnings:true"   \
 && spack config --scope site add "config:build_jobs:64"                \
 && spack config --scope site add "config:install_tree:root:/opt/software" \
 && spack config blame config

SHELL ["docker-shell"]

## Setup spack buildcache mirrors, including an internal
## spack mirror using the docker build cache, and
## a backup mirror on the internal B010 network
RUN --mount=type=cache,target=/var/cache/spack-mirror                   \
    export PATH=$PATH:$SPACK_ROOT/bin                                   \
 && spack mirror add docker /var/cache/spack-mirror                     \
 && spack mirror list

## Setup eic-spack buildcache mirrors (FIXME: leaks credentials into layer)
ARG S3_ACCESS_KEY=""
ARG S3_SECRET_KEY=""
RUN --mount=type=cache,target=/var/cache/spack-mirror                   \
    export PATH=$PATH:$SPACK_ROOT/bin                                   \
 && if [ -n $S3_ACCESS_KEY ] ; then                                     \
    spack mirror add --scope site                                       \
      --s3-endpoint-url https://dtn01.sdcc.bnl.gov:9000                 \
      --s3-access-key-id ${S3_ACCESS_KEY}                               \
      --s3-access-key-secret ${S3_SECRET_KEY}                           \
      eic-spack s3://eictest/EPIC/spack                                 \
    ; fi                                                                \
 && spack mirror list

## This variable will change whenevery either spack.yaml or our spack package
## overrides change, triggering a rebuild
ARG CACHE_BUST="hash"
ARG CACHE_NUKE=""

## Setup our custom package overrides
ENV EICSPACK_ROOT=${SPACK_ROOT}/var/spack/repos/eic-spack
ARG EICSPACK_ORGREPO="eic/eic-spack"
ARG EICSPACK_VERSION="$SPACK_VERSION"
ARG EICSPACK_CHERRYPICKS=""
ADD https://api.github.com/repos/${EICSPACK_ORGREPO}/commits/${EICSPACK_VERSION} /tmp/eic-spack.json
RUN git clone https://github.com/${EICSPACK_ORGREPO}.git ${EICSPACK_ROOT}     \
 && git -C ${EICSPACK_ROOT} checkout ${EICSPACK_VERSION}                \
 && if [ -n "${EICSPACK_CHERRYPICKS}" ] ; then                          \
      git -C ${EICSPACK_ROOT} cherry-pick -n ${EICSPACK_CHERRYPICKS} ;  \
    fi                                                                  \
 && spack repo add --scope site "${EICSPACK_ROOT}"

## Setup our custom environment
COPY spack.yaml /opt/spack-environment/
RUN rm -r /usr/local                                                    \
 && spack env activate /opt/spack-environment/                          \
 && spack concretize --fresh


## Now execute the main build (or fetch from cache if possible)
## note, no-check-signature is needed to allow the quicker signature-less
## packages from the internal (docker) buildcache
##
## Optional, nuke the buildcache after install, before (re)caching
## This is useful when going to completely different containers,
## or intermittently to keep the buildcache step from taking too much time
##
## Update the local build cache if needed. Consists of 3 steps:
## 1. Remove the B010 network buildcache (silicon)
## 2. Get a list of all packages, and compare with what is already on
##    the buildcache (using package hash)
## 3. Add packages that need to be added to buildcache if any
RUN --mount=type=cache,target=/var/cache/spack-mirror                   \
    cd /opt/spack-environment                                           \
 && ls /var/cache/spack-mirror                                          \
 && spack env activate .                                                \
 && status=0                                                            \
 && spack install -j64 --no-check-signature                             \
    || spack install -j64 --no-check-signature                          \
    || spack install -j64 --no-check-signature                          \
    || status=$?                                                        \
 && [ -z "${CACHE_NUKE}" ]                                              \
    || rm -rf /var/cache/spack-mirror/build_cache/*                     \
 && mkdir -p /var/cache/spack-mirror/build_cache                        \
 && spack buildcache update-index -d /var/cache/spack-mirror            \
 && spack buildcache list --allarch --very-long                         \
    | sed '/^$/d;/^--/d;s/@.\+//;s/\([a-z0-9]*\) \(.*\)/\2\/\1/'        \
    | sort > tmp.buildcache.txt                                         \
 && spack find --format {name}/{hash} | sort                            \
    | comm -23 - tmp.buildcache.txt                                     \
    | xargs --no-run-if-empty                                           \
      spack buildcache create --allow-root --only package --unsigned    \
                              --directory /var/cache/spack-mirror       \
                              --rebuild-index                           \
 && spack clean -a                                                      \
 && exit $status

## Extra post-spack steps:
##   - Python packages
COPY requirements.txt /usr/local/etc/requirements.txt
RUN --mount=type=cache,target=/var/cache/pip                            \
    echo "Installing additional python packages"                        \
 && cd /opt/spack-environment && spack env activate .                   \
 && python -m pip install                                               \
    --trusted-host pypi.org                                             \
    --trusted-host files.pythonhosted.org                               \
    --cache-dir /var/cache/pip                                          \
    --requirement /usr/local/etc/requirements.txt                       \
    --no-warn-script-location
    # ^ Supress not on PATH Warnings

## Including some small fixes:
##   - Somehow PODIO env isn't automatically set, 
##   - and Gaudi likes BINARY_TAG to be set
RUN cd /opt/spack-environment                                           \
 && echo -n ""                                                          \
 && echo "Grabbing environment info"                                    \
 && spack env activate --sh -d .                                        \
        | sed "s?LD_LIBRARY_PATH=?&/lib/x86_64-linux-gnu:?"             \
        | sed '/MANPATH/ s/;$/:;/'                                      \
    > /etc/profile.d/z10_spack_environment.sh                           \
 && cd /opt/spack-environment && spack env activate .                   \
 && echo -n ""                                                          \
 && echo "Add extra environment variables for Jug, Podio and Gaudi"     \
 && echo "export PODIO=$(spack location -i podio);"                     \
        >> /etc/profile.d/z10_spack_environment.sh                      \
 && echo -n ""                                                          \
 && echo "Executing cmake patch for dd4hep 16.1"                        \                
 && sed -i "s/FIND_PACKAGE(Python/#&/" /usr/local/cmake/DD4hepBuild.cmake

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
RUN cd /opt/spack-environment && spack env activate . && spack gc -y

## Bugfix to address issues loading the Qt5 libraries on Linux kernels prior to 3.15
## See
#https://askubuntu.com/questions/1034313/ubuntu-18-4-libqt5core-so-5-cannot-open-shared-object-file-no-such-file-or-dir
## and links therin for more info
RUN strip --remove-section=.note.ABI-tag /usr/local/lib/libQt5Core.so

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
ADD https://dl.min.io/client/mc/release/linux-amd64/mc /usr/local/bin
RUN chmod a+x /usr/local/bin/mc

## ========================================================================================
## STAGE 3
## Lean target image
## ========================================================================================
FROM ${DOCKER_REGISTRY}${BASE_IMAGE}:${INTERNAL_TAG}

LABEL maintainer="Sylvester Joosten <sjoosten@anl.gov>" \
      name="jug_xl" \
      march="amd64"

## copy over everything we need from staging in a single layer :-)
RUN --mount=from=staging,target=/staging                                \
    rm -rf /usr/local                                                   \
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
## TODO: move afterburner to spack when possible
ARG JUG_VERSION=1
ARG AFTERBURNER_VERSION=main
RUN echo "" >> /etc/jug_info                                            \
 && echo " - jug_dev: ${JUG_VERSION}" >> /etc/jug_info

## make sure we have the entrypoints setup correctly
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /
SHELL ["/usr/local/bin/eic-shell"]
