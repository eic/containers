# Builder with Argonne EIC software
#
FROM eicweb.phy.anl.gov:4567/containers/image_recipes/debian_spack:snapshot-20201117

LABEL maintainer="Sylvester Joosten <sjoosten@anl.gov>" \
      name="eic_builder" \
      group="eic_builder" \
      march="native" \
      basedist="debian" \
      base="debian"

ENV DOCKERFILE_BASE=debian            \
    DOCKERFILE_DISTRO=debian          \
    DOCKERFILE_DISTRO_VERSION=20201117-testing \
    SPACK_ROOT=/opt/spack             \
    DEBIAN_FRONTEND=noninteractive    \
    CURRENTLY_BUILDING_DOCKER_IMAGE=1 \
    container=docker

## install ghostview/ghostscript needed by some of the tools
RUN apt-get -yqq update \
 && apt-get -yqq install --no-install-recommends \
        ghostscript \
        gv \
 && rm -rf /var/lib/apt/lists/*

## Setup our environment definition
COPY spack.yaml /opt/spack-environment/spack.yaml

## Ensure an up-to-date custom package list
## TODO: We should just remove this from the upstream container
##       and only initialize the custom packages here for more
##       transparency
RUN rm -rf $SPACK_ROOT/np-spack \
 && echo "repos:" > $SPACK_ROOT/etc/spack/repos.yaml \
 && echo " - $SPACK_ROOT/np-spack" >> $SPACK_ROOT/etc/spack/repos.yaml
COPY np-spack $SPACK_ROOT/np-spack

## Install the software, no garbage collection at this stage
## as this is a raw builder image
RUN cd /opt/spack-environment \
 && spack env activate . \
 && spack install -j64 \
 && spack clean -a

## Install additional python packages
RUN cd /opt/spack-environment && spack env activate . \
 && pip install --trusted-host pypi.org \
                --trusted-host files.pythonhosted.org \
                --no-cache-dir \
        ipython matplotlib scipy yapf

# Modifications to the environment that are necessary to run
# Also make sure we keep the /lib/x86_65-linux-gnu in our PATH
RUN cd /opt/spack-environment \
 && spack env activate --sh -d . > /etc/profile.d/z10_spack_environment.sh \
 && sed -i "s?LD_LIBRARY_PATH=?&/lib/x86_64-linux-gnu:?" /etc/profile.d/z10_spack_environment.sh

# Add some extra environment variables
# Somehow PODIO env isn't automatically set, 
# and Gaudi likes BINARY_TAG to be set
RUN cd /opt/spack-environment \
 && spack env activate . \
 && export PODIO=`spack find -p podio | grep software | awk '{print $2}'` \
 && echo "export PODIO=${PODIO};" >> /etc/profile.d/z10_spack_environment.sh \
 && echo "export BINARY_TAG=x86_64-linux-gcc10-opt" >> /etc/profile.d/z10_spack_environment.sh

## make sure we have the entrypoints setup correctly
ENTRYPOINT []
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /
