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

RUN cd /tmp \
    && export VERSION=1.15.6 OS=linux ARCH=amd64 && \
    wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && \
    tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz && \
    rm go$VERSION.$OS-$ARCH.tar.gz 

RUN cd /tmp \
    && export PATH=/usr/local/go/bin:$PATH \
    && export VERSION=3.7.4 && \
    wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \ 
    tar -xzf singularity-${VERSION}.tar.gz && \
    cd singularity \
    && ./mconfig && \
    make -C builddir && \
    make -C builddir install

# Install Docker from Docker Inc. repositories. 
RUN export VERSION=20.10.17 \
 && curl -sSL https://get.docker.com/ | sh
# Install the magic wrapper. 
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker
# Define additional metadata for our image. 
VOLUME /var/lib/docker
CMD ["wrapdocker"]
