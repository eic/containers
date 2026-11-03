# shellcheck shell=bash
# shellcheck disable=SC2034  # Variables are used by scripts that source this file
## Debian release (codename) of the debian base image, i.e.
## debian:${DEBIAN_VERSION}-slim
##
## Single source of truth: scripts/build-base.sh sources this file to derive
## BASE_IMAGE for debian_stable_base, in GitHub Actions, GitLab CI and local
## builds alike. Values already set in the environment take precedence.
DEBIAN_VERSION="${DEBIAN_VERSION:-trixie}"
