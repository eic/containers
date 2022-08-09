# syntax=docker/dockerfile:1.2

# Container based on Jug_dev with Intel oneAPI support.

# Start with Debian-stable and layer oneAPI on top, prevents spack compiler errors.

## ========================================================================================
## STAGE 1: spack builder image
## EIC builder image with spack
## ========================================================================================

ARG DOCKER_REGISTRY="eicweb.phy.anl.gov:4567/containers/eic_container/"
# Internal Tag will be set by GitLab CI
ARG INTERNAL_TAG="testing"

FROM ${DOCKER_REGISTRY}debian_stable_base:${INTERNAL_TAG} as builder

## Install some extra spack dependencies
## Do not use Cache mount as it conflicts with oneapi stage
RUN                                                                        \
    rm -f /etc/apt/apt.conf.d/docker-clean                                 \
 && apt-get -yqq update                                                    \
 && apt-get -yqq install --no-install-recommends                           \
        python3                                                            \
        python3-dev                                                        \
        python3-distutils                                                  \
        python-is-python3                                                  \
 && rm -rf /var/lib/apt/lists/*


## Setup spack
## parts:
ARG SPACK_ROOT=/opt/spack
ARG SPACK_VERSION="develop"
ARG SPACK_CHERRYPICKS=""
RUN echo "Part 1: regular spack install (as in containerize)"           \
 && git clone https://github.com/spack/spack.git /tmp/spack-staging     \
 && cd /tmp/spack-staging                                               \
 && git checkout $SPACK_VERSION                                         \
 && if [ -n "$SPACK_CHERRYPICKS" ] ; then                               \
      git cherry-pick -n $SPACK_CHERRYPICKS ;                           \
    fi                                                                  \
 && cd -                                                                \
 && mkdir -p $SPACK_ROOT/opt/spack                                      \
 && cp -r /tmp/spack-staging/bin $SPACK_ROOT/bin                        \
 && cp -r /tmp/spack-staging/etc $SPACK_ROOT/etc                        \
 && cp -r /tmp/spack-staging/lib $SPACK_ROOT/lib                        \
 && cp -r /tmp/spack-staging/share $SPACK_ROOT/share                    \
 && cp -r /tmp/spack-staging/var $SPACK_ROOT/var                        \
 && cp -r /tmp/spack-staging/.git $SPACK_ROOT/.git                      \
 && rm -rf /tmp/spack-staging                                           \
 && echo 'export LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH'\ 
        >> $SPACK_ROOT/share/setup-env.sh                               \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash                \
          /usr/sbin/docker-shell                                        \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash                \
          /usr/sbin/interactive-shell                                   \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash                \
          /usr/sbin/spack-env                                           \
 && echo "Part 2: Set target to generic x86_64"                         \
 && echo "packages:" > $SPACK_ROOT/etc/spack/packages.yaml              \
 && echo "  all:" >> $SPACK_ROOT/etc/spack/packages.yaml                \
 && echo "    target: [x86_64]" >> $SPACK_ROOT/etc/spack/packages.yaml  \
 && cat $SPACK_ROOT/etc/spack/packages.yaml                             \
 && echo "Part 3: Set config to allow use of more cores for builds"     \
 && echo "(and some other settings)"                                    \
 && echo "config:" > $SPACK_ROOT/etc/spack/config.yaml                  \
 && echo "  suppress_gpg_warnings: true"                                \
        >> $SPACK_ROOT/etc/spack/config.yaml                            \
 && echo "  build_jobs: 64" >> $SPACK_ROOT/etc/spack/config.yaml        \
 && echo "  install_tree:" >> $SPACK_ROOT/etc/spack/config.yaml         \
 && echo "    root: /opt/software" >> $SPACK_ROOT/etc/spack/config.yaml \
 && cat $SPACK_ROOT/etc/spack/config.yaml

SHELL ["docker-shell"]

## Setup spack buildcache mirrors, including an internal
## spack mirror using the docker build cache, and
## a backup mirror on the internal B010 network
RUN --mount=type=cache,target=/var/cache/spack-mirror                   \
    export OLD_PATH=$PATH                                               \
 && export PATH=$PATH:$SPACK_ROOT/bin                                   \
 && spack mirror add docker /var/cache/spack-mirror                     \
 && spack mirror list

## This variable will change whenevery either spack.yaml or our spack package
## overrides change, triggering a rebuild
ARG CACHE_BUST="hash"
ARG CACHE_NUKE=""

## Setup our custom package overrides
ENV EICSPACK_ROOT=$SPACK_ROOT/var/spack/repos/eic-spack
ARG EICSPACK_VERSION="$SPACK_VERSION"
RUN git clone https://github.com/eic/eic-spack.git ${EICSPACK_ROOT}     \
 && git -C ${EICSPACK_ROOT} checkout ${EICSPACK_VERSION}                \
 && if [ -n "${EICSPACK_CHERRYPICKS}" ] ; then                          \
      git -C ${EICSPACK_ROOT} cherry-pick -n ${EICSPACK_CHERRYPICKS} ;  \
    fi                                                                  \
 && spack repo add --scope site "${EICSPACK_ROOT}"

## Setup our custom environment
COPY spack.yaml /opt/spack-environment/
RUN rm -r /usr/local                                                    \
 && spack env activate /opt/spack-environment/                          \
 && spack concretize


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
FROM builder AS staging

RUN cd /opt/spack-environment && spack env activate . && spack gc -y
# Strip all the binaries
# This reduces the image by factor of x2, so worth the effort
# note that we do not strip python libraries as can cause issues in some cases
RUN find -L /usr/local/*                                                \
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
RUN strip --remove-section=.note.ABI-tag /usr/local/lib/libQt5Core.so

## Address Issue #72
## missing precompiled headers for cppyy due to missing symlink in root
## install (should really be addressed by ROOT spack package)
RUN cd /opt/spack-environment && spack env activate .                   \
 && if [ ! -e $(spack location -i root)/lib/cppyy_backend/etc ]; then   \
      ln -sf $(spack location -i root)/etc                              \
             $(spack location -i root)/lib/cppyy_backend/etc;           \
    fi

RUN spack debug report                                                  \
      | sed "s/^/ - /" | sed "s/\* \*\*//" | sed "s/\*\*//"             \
    >> /etc/jug_info                                                    \
 && spack find --no-groups --long --variants | sed "s/^/ - /" >> /etc/jug_info

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
## STAGE 3: Set up Intel OneAPI Toolkit
## Use Intel's HPC-kit and Create Lean image from staging
## ========================================================================================

FROM intel/oneapi-basekit:2022.2-devel-ubuntu20.04 AS oneapi


COPY bashrc /root/.bashrc

ENV CLICOLOR_FORCE=1                                                    \
    LANGUAGE=en_US.UTF-8                                                \
    LANG=en_US.UTF-8                                                    \
    LC_ALL=en_US.UTF-8

## Install additional packages. Remove the auto-cleanup functionality
## for docker, as we're using the new buildkit cache instead.
## We install gcc-10 and g++-10 as they are not installed by default in
## Ubuntu 20.04
## TODO: libyaml-cpp-dev is a dependency for afterburner. We can probably remove
##       this once afterburner is added to spack
RUN --mount=type=cache,target=/var/cache/apt                            \
    rm -f /etc/apt/apt.conf.d/docker-clean                              \
 && ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime          \
 && echo "US/Eastern" > /etc/timezone                                   \
 && apt-get -yqq update                                                 \
 && apt-get -yqq upgrade                                                \
 && apt-get -yqq install --no-install-recommends                        \
        bc                                                              \
        ca-certificates                                                 \
        clang-format                                                    \
        clang-tidy                                                      \
        curl                                                            \
        file                                                            \
        build-essential                                                 \
        g++-10                                                          \
        gcc-10                                                          \
        gdb                                                             \
        ghostscript                                                     \
        gfortran-10                                                     \
        git                                                             \
        gnupg2                                                          \
        gv                                                              \
        iproute2                                                        \
        iputils-ping                                                    \
        iputils-tracepath                                               \
        less                                                            \
        libcbor-xs-perl                                                 \
        libjson-xs-perl                                                 \
        libyaml-cpp-dev                                                 \
        locales                                                         \
        lua-posix                                                       \
        make                                                            \
        nano                                                            \
        openssh-client                                                  \
        parallel                                                        \
        poppler-utils                                                   \
        python3                                                         \
        python3-dev                                                     \
        python3-distutils                                               \
        time                                                            \
        unzip                                                           \
        valgrind                                                        \
        vim-nox                                                         \
        wget                                                            \
 && localedef -i en_US -f UTF-8 en_US.UTF-8                             \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100  \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100  \
 && update-alternatives --install /usr/bin/gfortran gfortran            \
                                  /usr/bin/gfortran-10 100              \
 && gcc --version                                                       \
 && curl -L                                                             \
    "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" \
    | bash                                                              \
 && apt-get -yqq update                                                 \
 && apt-get -yqq install --no-install-recommends                        \
        gitlab-runner                                                   \
 && apt-get -yqq autoremove                                             \
 && rm -rf /var/lib/apt/lists/*                                         

## copy over everything we need from staging in a single layer
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

## make entrypoint executable and set up oneAPI environment
RUN chmod +x /usr/local/sbin/entrypoint.sh                              \
 && echo "source /opt/intel/oneapi/setvars.sh --force 2> /dev/null"     \
 >> /etc/profile

## make sure we have the entrypoints setup correctly
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /
SHELL ["/usr/local/bin/eic-shell"]
