## EIC spack organization and repository, e.g. eic/eic-spack
EICSPACK_ORGREPO="eic/eic-spack"

## EIC spack github version, e.g. v0.19.7 or commit hash
## note: nightly builds will use e.g. releases/v0.19
EICSPACK_VERSION="v0.19.5"

## Space-separated list of eic-spack cherry-picks
read -r -d '' EICSPACK_CHERRYPICKS <<- \
--- || true
f892e2b5d7ea9d1f2e43741499e899ce21dd3d5a
---
## Ref: https://github.com/eic/eic-spack/commit/[hash]
## [hash]: [description]
## f892e2b5d7ea9d1f2e43741499e899ce21dd3d5a: py-minkowskiengine: new package
