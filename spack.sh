## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v1.0
SPACK_VERSION="v1.0.2"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
09f75ee426a2e05e0543570821582480ff823ba5
a462612b64e97fa7dfe461c32c58553fd6ec63c5
292b0dcaba3b2a5e3f9668d205d39fee2c715721
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## 09f75ee426a2e05e0543570821582480ff823ba5: setup-env.sh: if exe contains qemu, use /proc/$$/comm instead
## a462612b64e97fa7dfe461c32c58553fd6ec63c5: fix: allow versions with git attr in packages without git attr
## 292b0dcaba3b2a5e3f9668d205d39fee2c715721: fix: write created time field with OCI buildcache config
