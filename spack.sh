# shellcheck shell=bash
# shellcheck disable=SC2034  # Variables are used by scripts that source this file
## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="SebastianPaucar/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v1.0
SPACK_VERSION="feature/debuggable-installations-v1.2.2"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: this branch is v1.2.2 + the two upstream fixes below, cherry-picked
## directly onto the branch (since SPACK_ORGREPO no longer points at
## spack/spack, the normal cherry-pick mechanism can't fetch them) + the
## debuggable-installations feature work.
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## 292b0dcaba3b2a5e3f9668d205d39fee2c715721: fix: write created time field with OCI buildcache config
## 678e506a95b319c573ba7e84703b06d7275ab80e: fix: don't map prefix to view root for pkgs excluded from view
