# shellcheck shell=bash
# shellcheck disable=SC2034  # Variables are used by scripts that source this file
## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v1.0
SPACK_VERSION="v1.2.0"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
292b0dcaba3b2a5e3f9668d205d39fee2c715721
678e506a95b319c573ba7e84703b06d7275ab80e
52bef0e63711a0b63816b3f4b1561df5b158db65
44fa40a0367ab59f756fc24791395e1ec56d2712
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## 292b0dcaba3b2a5e3f9668d205d39fee2c715721: fix: write created time field with OCI buildcache config
## 678e506a95b319c573ba7e84703b06d7275ab80e: fix: don't map prefix to view root for pkgs excluded from view
## 52bef0e63711a0b63816b3f4b1561df5b158db65: fix: install missing upstream packages in local store
## 44fa40a0367ab59f756fc24791395e1ec56d2712: view: fix rename on overlayfs issue
