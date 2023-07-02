FROM ubuntu:22.04
LABEL maintainer="Whitney Armstrong <warmstrong@anl.gov>" \
      name="ubuntu_dind" \
      group="ubuntu_dind" \
      march="native" \
      base="ubuntu" \
      version="22.04"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-transport-https \
    binfmt-support \
    build-essential \
    ca-certificates \
    cryptsetup \
    curl \
    gettext \
    git \
    iptables \
    libglib2.0-dev \
    libgpgme11-dev \
    libseccomp-dev \
    libssl-dev \
    lxc \
    make \
    pkg-config \
    qemu \
    qemu-user-static \
    uuid-dev \
    squashfs-tools \
    wget

# Install Go
ARG GO_OS=linux
ARG GO_ARCH=amd64
ARG GO_VERSION=1.20.5
ARG GO_URL=https://dl.google.com/go/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
RUN curl -L ${GO_URL} | tar -C /usr/local -xzvf -

# Install Singularity CE
ARG SINGULARITY_VERSION=3.11.4
ARG SINGULARITY_URL=https://github.com/sylabs/singularity/releases/download/v${SINGULARITY_VERSION}/singularity-ce-${SINGULARITY_VERSION}.tar.gz
RUN curl -L ${SINGULARITY_URL} | tar -C /tmp -xzf - \
 && cd /tmp/singularity-ce-${SINGULARITY_VERSION} \
 && export PATH=/usr/local/go/bin:$PATH \
 && ./mconfig \
 && make -C builddir \
 && make -C builddir install \
 && rm -rf /tmp/singularity-ce-${SINGULARITY_VERSION}

# Install Docker
ARG DOCKER_VERSION=24
ADD https://get.docker.com/ /tmp/get-docker.sh
RUN bash /tmp/get-docker.sh --version ${DOCKER_VERSION}

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker
CMD ["wrapdocker"]
