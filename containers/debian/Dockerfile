#syntax=docker/dockerfile:1.2

# Minimal container based on Debian Testing for up-to-date packages. 
# Very lightweight container with a minimal build environment

FROM  amd64/debian:testing-20210408-slim
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
## We also install gitlab-runner, from the buster package (as bullseye is not available atm)
RUN --mount=type=cache,target=/var/cache/apt                            \
    rm -f /etc/apt/apt.conf.d/docker-clean                              \
 && apt-get -yqq update                                                 \
 && apt-get -yqq install --no-install-recommends                        \
        ca-certificates                                                 \
        curl                                                            \
        file                                                            \
        build-essential                                                 \
        g++-10                                                          \
        gcc-10                                                          \
        gfortran-10                                                     \
        git                                                             \
        gnupg2                                                          \
        iproute2                                                        \
        iputils-ping                                                    \
        locales                                                         \
        lua-posix                                                       \
        make                                                            \
        unzip                                                           \
        nano                                                            \
        vim-nox                                                         \
        less                                                            \
        clang-format                                                    \
        openssh-client                                                  \
        wget                                                            \
        ghostscript                                                     \
        gv                                                              \
        poppler-utils                                                   \
        parallel                                                        \
        time                                                            \
        valgrind                                                        \
 && localedef -i en_US -f UTF-8 en_US.UTF-8                             \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100  \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100  \
 && update-alternatives --install /usr/bin/gfortran gfortran            \
                                  /usr/bin/gfortran-10 100              \
 && cc --version                                                        \
 && curl -L                                                             \
    "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" \
    | bash                                                              \
 && sed -i "s/bullseye/buster/"                                         \
           /etc/apt/sources.list.d/runner_gitlab-runner.list            \
 && apt-get -yqq update                                                 \
 && apt-get -yqq install --no-install-recommends                        \
        gitlab-runner                                                   \
 && apt-get -yqq autoremove                                             \
 && rm -rf /var/lib/apt/lists/*                                         

