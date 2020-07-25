# Release container for Argonne EIC software
# Copy over relevant files from builder
#
FROM eicweb.phy.anl.gov:4567/containers/eic_container/eic_builder:latest as builder
RUN cd /opt/spack-environment && spack env activate . && spack gc -y

FROM eicweb.phy.anl.gov:4567/containers/image_recipes/ubuntu_minimal:20.04
LABEL maintainer="Sylvester Joosten <sjoosten@anl.gov>" \
      name="eic_container" \
      group="eic_container" \
      march="native" \
      basedist="ubuntu" \
      base="ubuntu"

ENV DOCKERFILE_BASE=ubuntu            \
    DOCKERFILE_DISTRO=ubuntu          \
    DOCKERFILE_DISTRO_VERSION=20.04   \
    DEBIAN_FRONTEND=noninteractive    \
    CURRENTLY_BUILDING_DOCKER_IMAGE=1 \
    container=docker

## Copy over files from builder
COPY --from=builder /opt/spack-environment /opt/spack-environment
COPY --from=builder /opt/software /opt/software
COPY --from=builder /opt/view /opt/view
COPY --from=builder /etc/profile.d/z10_spack_environment.sh /etc/profile.d/z10_spack_environment.sh
## Setup global bashrc, useful for singularity
COPY --from=builder /root/.bashrc /etc/bash.bashrc
COPY eic-shell /usr/local/bin/eic-shell
COPY --from=builder /etc/profile.d/z10_spack_environment.sh /etc/eic-env.sh

## make sure we have the entrypoints setup correctly
ENTRYPOINT []
CMD ["bash", "--rcfile", "/etc/profile", "-l"]
USER 0
WORKDIR /
SHELL ["/usr/local/bin/eic-shell"]
