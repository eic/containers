#syntax=docker/dockerfile:1.2

# Minimal container based on Debian Testing for up-to-date packages. 
# Very lightweight container with a minimal build environment

FROM  amd64/debian:testing-20211220-slim
LABEL maintainer="Sylvester Joosten <sjoosten@anl.gov>" \
      name="debian_base" \
      march="amd64"

COPY bashrc /root/.bashrc

ENV CLICOLOR_FORCE=1                                                    \
    LANGUAGE=en_US.UTF-8                                                \
    LANG=en_US.UTF-8                                                    \
    LC_ALL=en_US.UTF-8

## Install additional packages. Remove the auto-cleanup functionality
## for docker, as we're using the new buildkit cache instead.
## We also install gitlab-runner, from the bullseye package (as bookworm is not available atm)
## TODO: libyaml-cpp-dev is a dependency for afterburner. We can probably remove
##       this once afterburner is added to spack
RUN --mount=type=cache,target=/var/cache/apt                            \
    rm -f /etc/apt/apt.conf.d/docker-clean                              \
 && ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime          \
 && echo "US/Eastern" > /etc/timezone                                   \
 && apt-mark hold libc6 libc-bin                                        \
 && apt-get -yqq update                                                 \
 && apt-get -yqq install --no-install-recommends                        \
        bc                                                              \
        ca-certificates                                                 \
        clang-format                                                    \
        clang-tidy                                                      \
        curl                                                            \
        file                                                            \
        build-essential                                                 \
        g++-11                                                          \
        gcc-11                                                          \
        gdb                                                             \
        gfortran-11                                                     \
        ghostscript                                                     \
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
        time                                                            \
        unzip                                                           \
        valgrind                                                        \
        vim-nox                                                         \
        wget                                                            \
 && localedef -i en_US -f UTF-8 en_US.UTF-8                             \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100  \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100  \
 && update-alternatives --install /usr/bin/gfortran gfortran            \
                                  /usr/bin/gfortran-11 100              \
 && gcc --version                                                       \
 && curl -L                                                             \
    "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" \
    | bash                                                              \
 && sed -i "s/bookworm/bullseye/"                                       \
           /etc/apt/sources.list.d/runner_gitlab-runner.list            \
 && apt-get -yqq update                                                 \
 && apt-get -yqq install --no-install-recommends                        \
        gitlab-runner                                                   \
 && apt-get -yqq autoremove                                             \
 && rm -rf /var/lib/apt/lists/*                                         

