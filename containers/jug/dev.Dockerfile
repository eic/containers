#syntax=docker/dockerfile:1.2
ARG DOCKER_REGISTRY="eicweb.phy.anl.gov:4567/containers/eic_container/"
ARG INTERNAL_TAG="testing" 

ARG SPACK_ROOT="/opt/spack"
ARG SPACK_SOFT="/opt/software"
ARG SPACK_VIEW="/usr/local"
ARG SPACK_ENV="/opt/spack-environment"

## ========================================================================================
## STAGE1: spack builder image
## EIC builder image with spack
## ========================================================================================
FROM ${DOCKER_REGISTRY}debian_base:${INTERNAL_TAG} as builder
ARG SPACK_ROOT
ARG SPACK_SOFT
ARG SPACK_VIEW
ARG SPACK_ENV

## instal some extra spack dependencies
RUN --mount=type=cache,target=/var/cache/apt                            \
    rm -f /etc/apt/apt.conf.d/docker-clean                              \
 && apt-get -yqq update                                                 \
 && apt-get -yqq install --no-install-recommends                        \
        python3                                                         \
        python3-distutils                                               \
        python-is-python3                                               \
 && rm -rf /var/lib/apt/lists/*

## Setup spack
## parts:
ARG SPACK_VERSION="develop"
ARG SPACK_CHERRYPICKS=""
RUN echo "Part 1: regular spack install (as in containerize)"           \
 && mkdir -p ${SPACK_ROOT}                                              \
 && git clone https://github.com/spack/spack.git ${SPACK_ROOT}          \
 && git -C ${SPACK_ROOT} checkout $SPACK_VERSION                        \
 && if [ -n "$SPACK_CHERRYPICKS" ] ; then                               \
      git -C ${SPACK_ROOT} cherry-pick -n $SPACK_CHERRYPICKS ;          \
    fi                                                                  \
 && ln -s ${SPACK_ROOT}/share/spack/docker/entrypoint.bash              \
          /usr/sbin/docker-shell                                        \
 && ln -s ${SPACK_ROOT}/share/spack/docker/entrypoint.bash              \
          /usr/sbin/interactive-shell                                   \
 && ln -s ${SPACK_ROOT}/share/spack/docker/entrypoint.bash              \
          /usr/sbin/spack-env                                           \
 && echo "Part 2: Set target to generic x86_64"                         \
 && echo "packages:" > ${SPACK_ROOT}/etc/spack/packages.yaml            \
 && echo "  all:" >> ${SPACK_ROOT}/etc/spack/packages.yaml              \
 && echo "    target: [x86_64]" >> ${SPACK_ROOT}/etc/spack/packages.yaml \
 && cat ${SPACK_ROOT}/etc/spack/packages.yaml                           \
 && echo "Part 3: Set config to allow use of more cores for builds"     \
 && echo "(and some other settings)"                                    \
 && echo "config:" > ${SPACK_ROOT}/etc/spack/config.yaml                \
 && echo "  suppress_gpg_warnings: true"                                \
        >> ${SPACK_ROOT}/etc/spack/config.yaml                          \
 && echo "  build_jobs: 64" >> ${SPACK_ROOT}/etc/spack/config.yaml      \
 && echo "  install_tree:" >> ${SPACK_ROOT}/etc/spack/config.yaml       \
 && echo "    root: ${SPACK_SOFT}" >> ${SPACK_ROOT}/etc/spack/config.yaml \
 && cat ${SPACK_ROOT}/etc/spack/config.yaml

SHELL ["docker-shell"]

## Setup spack buildcache mirrors, including an internal
## spack mirror using the docker build cache, and
## a backup mirror on the internal B010 network
RUN --mount=type=cache,target=/var/cache/spack-mirror                   \
    export PATH=$PATH:${SPACK_ROOT}/bin                                 \
 && wget 10.10.241.24/spack-mirror/sodium.pub --no-check-certificate    \
 && spack gpg trust sodium.pub                                          \
 && spack mirror add silicon http://10.10.241.24/spack-mirror           \
 && spack mirror add docker /var/cache/spack-mirror                     \
 && spack mirror list

## Setup our custom environment and package overrides
COPY spack ${SPACK_ROOT}/eic-spack
RUN spack repo add --scope site "${SPACK_ROOT}/eic-spack"               \
 && mkdir -p ${SPACK_ENV}                                               \
 && mv ${SPACK_ROOT}/eic-spack/spack.yaml ${SPACK_ENV}                  \
 && rm -rf ${SPACK_VIEW}                                                \
 && spack env create --with-view ${SPACK_VIEW} --dir ${SPACK_ENV}       \
 && spack env activate ${SPACK_ENV}                                     \
 && spack concretize

## This variable will change whenevery either spack.yaml or our spack package
## overrides change, triggering a rebuild
ARG CACHE_BUST="hash"
ARG CACHE_NUKE=""

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
    spack env activate ${SPACK_ENV}                                     \
 && status=0                                                            \
 && spack install -j64 --no-check-signature                             \
    || spack install -j64 --no-check-signature                          \
    || spack install -j64 --no-check-signature                          \
    || status=$?                                                        \
 && [ -z "${CACHE_NUKE}" ]                                              \
    || rm -rf /var/cache/spack-mirror/build_cache/*                     \
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
COPY requirements.txt ${SPACK_VIEW}/etc/requirements.txt
RUN --mount=type=cache,target=/var/cache/pip                            \

    spack env activate ${SPACK_ENV}                                     \
 && pip install --trusted-host pypi.org                                 \
                --trusted-host files.pythonhosted.org                   \
                --cache-dir /var/cache/pip                              \
                --requirement ${SPACK_VIEW}/etc/requirements.txt

## Set environment
RUN spack env activate --sh -d ${SPACK_ENV}                             \
        | sed "s?LD_LIBRARY_PATH=?&/lib/x86_64-linux-gnu:?"             \
        | sed '/MANPATH/ s/;$/:;/'                                      \
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
ARG SPACK_ROOT
ARG SPACK_SOFT
ARG SPACK_VIEW
ARG SPACK_ENV

# Garbage collect
RUN spack env activate ${SPACK_ENV} && spack gc -y

# Strip all the binaries
# This reduces the image by factor of x2, so worth the effort
# note that we do not strip python libraries as can cause issues in some cases
RUN find -L ${SPACK_VIEW}/*                                             \
         -type d -name site-packages -prune -false -o                   \
         -type f -not -name "zdll.lib" -not -name libtensorflow-lite.a  \
         -exec realpath '{}' \;                                      \
      | xargs file -i                                                   \
      | grep 'charset=binary'                                           \
      | grep 'x-executable\|x-archive\|x-sharedlib'                     \
      | awk -F: '{print $1}' | xargs strip -s

## Bugfix to address issues loading the Qt5 libraries on Linux kernels prior to 3.15
## See
#https://askubuntu.com/questions/1034313/ubuntu-18-4-libqt5core-so-5-cannot-open-shared-object-file-no-such-file-or-dir
## and links therin for more info
RUN strip --remove-section=.note.ABI-tag ${SPACK_VIEW}/lib/libQt5Core.so

## Address Issue #72
## missing precompiled headers for cppyy due to missing symlink in root
## install (should really be addressed by ROOT spack package)
RUN spack env activate ${SPACK_ENV}                                     \
 && if [ ! -e $(spack location -i root)/lib/cppyy_backend/etc ]; then   \
      ln -sf $(spack location -i root)/etc                              \
             $(spack location -i root)/lib/cppyy_backend/etc;           \
    fi

RUN spack debug report                                                  \
      | sed "s/^/ - /" | sed "s/\* \*\*//" | sed "s/\*\*//"             \
    >> /etc/jug_info                                                    \
 && spack find --no-groups --long --variants | sed "s/^/ - /" >> /etc/jug_info

COPY eic-shell ${SPACK_VIEW}/bin/eic-shell
COPY eic-info ${SPACK_VIEW}/bin/eic-info
COPY entrypoint.sh ${SPACK_VIEW}/sbin/entrypoint.sh
COPY eic-env.sh /etc/eic-env.sh
COPY profile.d/a00_cleanup.sh /etc/profile.d
COPY profile.d/z11_jug_env.sh /etc/profile.d
COPY singularity.d /.singularity.d

## Add minio client into ${SPACK_VIEW}/bin
ADD https://dl.min.io/client/mc/release/linux-amd64/mc ${SPACK_VIEW}/bin
RUN chmod a+x ${SPACK_VIEW}/bin/mc

## ========================================================================================
## STAGE 3
## Lean target image
## ========================================================================================
FROM ${DOCKER_REGISTRY}debian_base:${INTERNAL_TAG}
ARG SPACK_ROOT
ARG SPACK_SOFT
ARG SPACK_VIEW
ARG SPACK_ENV

LABEL maintainer="Sylvester Joosten <sjoosten@anl.gov>" \
      name="jug_xl" \
      march="amd64"

## copy over everything we need from staging in a single layer :-)
RUN --mount=from=staging,target=/staging                                \
    rm -rf ${SPACK_VIEW}                                                \
 && cp -r /staging${SPACK_ENV} ${SPACK_ENV}                             \
 && cp -r /staging${SPACK_SOFT} ${SPACK_SOFT}                           \
 && cp -r /staging/usr/._local /usr/._local                             \
 && cd /usr/._local                                                     \
 && PREFIX_PATH=$(realpath $(ls | tail -n1))                            \
 && echo "Found spack true prefix path to be $PREFIX_PATH"              \
 && cd -                                                                \
 && ln -s ${PREFIX_PATH} ${SPACK_VIEW}                                  \
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
ENTRYPOINT ["${SPACK_VIEW}/sbin/entrypoint.sh"]
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /
SHELL ["${SPACK_VIEW}/bin/eic-shell"]
