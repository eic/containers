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
2b588bdf631a22a55630981aa69365197a9258f7
2ec34f3a913fe32017682ccbc9518b7111255f6b
69329c85739c6030d6f60c00aa03ebcaf4e22037
44fa40a0367ab59f756fc24791395e1ec56d2712
b5b06bc036896af346e9ca16ac1183af4333eed7
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## 292b0dcaba3b2a5e3f9668d205d39fee2c715721: fix: write created time field with OCI buildcache config
## 678e506a95b319c573ba7e84703b06d7275ab80e: fix: don't map prefix to view root for pkgs excluded from view
## 2b588bdf631a22a55630981aa69365197a9258f7: fix: install missing upstream packages in local store
## 2ec34f3a913fe32017682ccbc9518b7111255f6b: fix: install missing upstream packages in local store (new installer)
## 69329c85739c6030d6f60c00aa03ebcaf4e22037: fix: also avoid raise InstallError later in new_installer; add unit-test
## 44fa40a0367ab59f756fc24791395e1ec56d2712: view: fix rename on overlayfs issue
## b5b06bc036896af346e9ca16ac1183af4333eed7: solver: improve decisions on build_set_id
