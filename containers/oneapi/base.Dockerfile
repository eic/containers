#syntax=docker/dockerfile:1.2
ARG BASEIMAGE="intel/oneapi-hpckit:2022.2-devel-ubuntu20.04"

# Minimal container based on Intel oneAPI for up-to-date packages. 
# Very lightweight container with a minimal build environment (LOL)

FROM  ${BASEIMAGE}
LABEL maintainer="Wouter Deconinck <wouter.deconinck@umanitoba.ca"      \
      name="oneapi_base"                                                \
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
        gdb                                                             \
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
 && gcc --version                                                       \
 && curl -L                                                             \
    "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" \
    | bash                                                              \
 && sed -i "s/bookworm/buster/"                                         \
           /etc/apt/sources.list.d/runner_gitlab-runner.list            \
 && apt-get -yqq update                                                 \
 && apt-get -yqq install --no-install-recommends                        \
        gitlab-runner                                                   \
 && apt-get -yqq autoremove                                             \
 && rm -rf /var/lib/apt/lists/*                                         
