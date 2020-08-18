# Builder with Argonne EIC software
#
FROM eicweb.phy.anl.gov:4567/containers/image_recipes/ubuntu_spack:0.15.3

LABEL maintainer="Sylvester Joosten <sjoosten@anl.gov>" \
      name="eic_builder" \
      group="eic_builder" \
      march="native" \
      basedist="ubuntu" \
      base="ubuntu"

ENV DOCKERFILE_BASE=ubuntu            \
    DOCKERFILE_DISTRO=ubuntu          \
    DOCKERFILE_DISTRO_VERSION=20.04   \
    SPACK_ROOT=/opt/spack             \
    DEBIAN_FRONTEND=noninteractive    \
    CURRENTLY_BUILDING_DOCKER_IMAGE=1 \
    container=docker

## Ensure an up-to-date custom package list
RUN rm -rf $SPACK_ROOT/np-spack \
 && echo "Update spack for v2.1.3" \
 && git clone https://eicweb.phy.anl.gov/EIC/np-spack.git $SPACK_ROOT/np-spack \
 && cd $SPACK_ROOT/np-spack && git checkout v`spack --version` && cd - \
 && rm -rf $SPACK_ROOT/np-spack/.git \
 && echo "repos:" > $SPACK_ROOT/etc/spack/repos.yaml \
 && echo " - $SPACK_ROOT/np-spack" >> $SPACK_ROOT/etc/spack/repos.yaml

## Setup our environment definition
COPY spack.yaml /opt/spack-environment/spack.yaml

## Install the software, no garbage collection at this stage
## as this is a raw builder image
RUN cd /opt/spack-environment \
 && spack env activate . \
 && spack install -j32 \
 && spack clean -a

## Install additional python packages
RUN cd /opt/spack-environment && spack env activate . \
 && pip install --trusted-host pypi.org \
                --trusted-host files.pythonhosted.org \
                --no-cache-dir \
        ipython matplotlib scipy yapf

## --> disabled for now as we are changing them by the hour
## Build elements prone to change here, to allow us to rebuild
## from runner cache efficiently
#RUN cd /opt/spack-environment \
 #&& spack env activate . \
 #&& spack add npdet@master \
 #&& spack add eicd@master \
 #&& spack install \
 #&& spack clean -a

## Strip the binaries
#RUN find -L /usr/local/* -type f -exec readlink -f '{}' \; | \
#    xargs file -i | \
#    grep 'charset=binary' | \
#    grep 'x-executable\|x-archive\|x-sharedlib' | \
#    awk -F: '{print $1}' | xargs strip -s

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
 && echo "export BINARY_TAG=x86_64-linux-gcc9-opt" >> /etc/profile.d/z10_spack_environment.sh

## make sure we have the entrypoints setup correctly
ENTRYPOINT []
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /
