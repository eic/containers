# shellcheck shell=bash
# shellcheck disable=SC2034  # Variables are used by scripts that source this file
## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v1.0
SPACK_VERSION="v1.2.2"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
292b0dcaba3b2a5e3f9668d205d39fee2c715721
473d1459fba532de0d3d7edc34d27b1432bc90cd
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## 292b0dcaba3b2a5e3f9668d205d39fee2c715721: fix: write created time field with OCI buildcache config
## 473d1459fba532de0d3d7edc34d27b1432bc90cd: fix: don't map prefix to view root for pkgs excluded from view
