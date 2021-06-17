#syntax=docker/dockerfile:1.2
ARG INTERNAL_TAG="testing" 

## ========================================================================================
## STAGE1: spack builder image
## EIC builder image with spack
## ========================================================================================
FROM eicweb.phy.anl.gov:4567/containers/eic_container/debian_base:${INTERNAL_TAG} as builder

## instal some extra spack dependencies
RUN --mount=type=cache,target=/var/cache/apt                            \
    rm -f /etc/apt/apt.conf.d/docker-clean                              \
 && apt-get -yqq update                                                 \
 && apt-get -yqq install --no-install-recommends                        \
        python3                                                         \
        python3-pip                                                     \
        python3-setuptools                                              \
        tcl                                                             \
        uuid-dev                                                        \
        libfcgi-dev                                                     \
        x11proto-xext-dev                                               \
 && pip3 install boto3                                                  \ 
 && rm -rf /var/lib/apt/lists/*

## Setup spack
## parts:
ENV SPACK_ROOT=/opt/spack
ARG SPACK_VERSION="develop"
RUN echo "Part 1: regular spack install (as in containerize)"           \
 && git clone https://github.com/spack/spack.git /tmp/spack-staging     \
 && cd /tmp/spack-staging && git checkout $SPACK_VERSION && cd -        \
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
    export PATH=$PATH:$SPACK_ROOT/bin                                   \
 && wget 10.10.241.24/spack-mirror/sodium.pub --no-check-certificate    \
 && spack gpg trust sodium.pub                                          \
 && spack mirror add silicon http://10.10.241.24/spack-mirror           \
 && spack mirror add docker /var/cache/spack-mirror                     \
 && spack mirror list

## Setup our custom environment and package overrides
COPY spack $SPACK_ROOT/eic-spack
RUN echo "repos:" > $SPACK_ROOT/etc/spack/repos.yaml                    \
 && echo " - $SPACK_ROOT/eic-spack" >> $SPACK_ROOT/etc/spack/repos.yaml \
 && mkdir /opt/spack-environment                                        \
 && mv $SPACK_ROOT/eic-spack/spack.yaml /opt/spack-environment/spack.yaml

## This variable will change whenevery either spack.yaml or our spack package
## overrides change, triggering a rebuild
ARG CACHE_BUST="hash"
## Now execute the main build (or fetch from cache if possible)
## note, no-check-signature is needed to allow the quicker signature-less
## packages from the internal (docker) buildcache
RUN --mount=type=cache,target=/var/cache/spack-mirror                   \
    cd /opt/spack-environment                                           \
 && ls /var/cache/spack-mirror                                          \
 && spack env activate .                                                \
 && spack install -j64 --no-check-signature                             \
 && spack clean -a

## Update the local build cache if needed. Consists of 3 steps:
## 1. Remove the B010 network buildcache (silicon)
## 2. Get a list of all packages, and compare with what is already on
##    the buildcache (using package hash)
## 3. Add packages that need to be added to buildcache if any
RUN --mount=type=cache,target=/var/cache/spack-mirror                   \
    spack mirror remove silicon                                         \
 && spack buildcache list --allarch --long                              \
     | grep -v -e '---'                                                 \
     | sed "s/@.\+//"                                                   \
     | sort > tmp.buildcache.txt                                        \
 && spack find --no-groups --long                                       \
     | tail -n +2                                                       \
     | grep -v "==>"                                                    \
     | sed "s/@.\+//"                                                   \
     | sort > tmp.manifest.txt                                          \
 && comm -23 tmp.manifest.txt tmp.buildcache.txt                        \
     > tmp.needsupdating.txt                                            \
 && if [ $(wc -l < tmp.needsupdating.txt) -ge 1 ]; then                 \
     cat tmp.needsupdating.txt                                          \
        | awk '{print($2);}'                                            \
        | tr '\n' ' '                                                   \
        | xargs spack buildcache create -uaf -d /var/cache/spack-mirror \
     && spack buildcache update-index -d /var/cache/spack-mirror;       \
    fi                                                                  \
 && rm tmp.manifest.txt                                                 \
 && rm tmp.buildcache.txt                                               \
 && rm tmp.needsupdating.txt

## extra post-spack steps
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
 && cd /opt/spack-environment                                           \
 && echo -n ""                                                          \
 && echo "Add extra environment variables for Jug, Podio and Gaudi"     \
 && spack env activate .                                                \
 && export PODIO=`spack find -p podio                                   \
        | grep software                                                 \
        | awk '{print $2}'`                                             \
 && echo "export PODIO=${PODIO};"                                       \
        >> /etc/profile.d/z10_spack_environment.sh                      \
 && cd /opt/spack-environment && spack env activate .                   \
 && echo -n ""                                                          \
 && echo "Installing additional python packages"                        \
 && pip install --trusted-host pypi.org                                 \
                --trusted-host files.pythonhosted.org                   \
                --no-cache-dir                                          \
        ipython matplotlib scipy yapf pandas pycairo pyyaml             \
        jupyter jupyterlab uproot pyunfold seaborn                      \
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

RUN cd /opt/spack-environment && spack env activate . && spack gc -y
# Strip all the binaries
# This reduces the image by factor of x2, so worth the effort
# note that we do not strip python libraries as can cause issues in some cases
RUN find -L /usr/local/*                                                \
         -type d -name site-packages -prune -false -o                   \
         -type f -not -name "zdll.lib"                                  \
         -exec readlink -f '{}' \;                                      \
      | xargs file -i                                                   \
      | grep 'charset=binary'                                           \
      | grep 'x-executable\|x-archive\|x-sharedlib'                     \
      | awk -F: '{print $1}' | xargs strip -s

## Bugfix to address issues loading the Qt5 libraries on Linux kernels prior to 3.15
## See
#https://askubuntu.com/questions/1034313/ubuntu-18-4-libqt5core-so-5-cannot-open-shared-object-file-no-such-file-or-dir
## and links therin for more info
RUN strip --remove-section=.note.ABI-tag /usr/local/lib/libQt5Core.so

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

## ========================================================================================
## STAGE 3
## Lean target image
## ========================================================================================
FROM eicweb.phy.anl.gov:4567/containers/eic_container/debian_base:${INTERNAL_TAG}

LABEL maintainer="Sylvester Joosten <sjoosten@anl.gov>" \
      name="jug_xl" \
      march="amd64"

## copy over everything we need from staging in a single layer :-)
RUN --mount=from=staging,target=/staging                                \
    rm -rf /usr/local                                                   \
 && cp -r /staging/opt/software /opt/software                           \
 && cp -r /staging/usr/local /usr/local                                 \
 && cp /staging/etc/profile.d/*.sh /etc/profile.d/                      \
 && cp /staging/etc/eic-env.sh /etc/eic-env.sh                          \
 && cp /staging/etc/jug_info /etc/jug_info                              \
 && cp -r /staging/.singularity.d /.singularity.d                        

ARG JUG_VERSION=1
RUN echo "" >> /etc/jug_info                                            \
 && echo " - jug_dev: ${JUG_VERSION}" >> /etc/jug_info

## make sure we have the entrypoints setup correctly
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /
SHELL ["/usr/local/bin/eic-shell"]
