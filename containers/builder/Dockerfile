# Builder with Argonne EIC software
#
FROM eicweb.phy.anl.gov:4567/containers/image_recipes/eic_spack:1.0.0

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
 && git clone https://eicweb.phy.anl.gov/EIC/np-spack.git $SPACK_ROOT/np-spack \
 && rm -rf $SPACK_ROOT/np-spack/.git \
 && echo "repos:" > $SPACK_ROOT/etc/spack/repos.yaml \
 && echo " - $SPACK_ROOT/np-spack" >> $SPACK_ROOT/etc/spack/repos.yaml

## Install the software, building on the existing root environment.
## This is a raw builder image, so no calls to spack gc
## FIXME: eigen should be explicitly added upstream
RUN cd /opt/spack-environment && spack env activate . \
 && spack add npdet@master \
 && spack add eigen \
 && spack install \
 && spack clean -a

## FIXME: ipython etc should be added upstream
RUN cd /opt/spack-environment && spack env activate . \
 && pip install --trusted-host pypi.org \
                --trusted-host files.pythonhosted.org \
                --no-cache-dir \
        ipython matplotlib scipy

## Strip the binaries
RUN find -L /opt/view/* -type f -exec readlink -f '{}' \; | \
    xargs file -i | \
    grep 'charset=binary' | \
    grep 'x-executable\|x-archive\|x-sharedlib' | \
    awk -F: '{print $1}' | xargs strip -s

# Modifications to the environment that are necessary to run
RUN cd /opt/spack-environment && \
    spack env activate --sh -d . >> /etc/profile.d/z10_spack_environment.sh && \
    echo "export BINARY_TAG=x86_64-linux-gcc9-opt" >> /etc/profile.d/z10_spack_environment.sh

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l", "-c"]
CMD ["bash"]
