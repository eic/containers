# shellcheck shell=bash
# shellcheck disable=SC2034  # Variables are used by scripts that source this file
## Spack organization and repository, e.g. spack/spack-packages
SPACKPACKAGES_ORGREPO="spack/spack-packages"

## Spack github version, e.g. v2025.07.0 or commit hash
## Note: nightly builds will use e.g. develop
## Note: when changing this, also make new buildcache public
## (default is only visible with internal authentication)
SPACKPACKAGES_VERSION="v2026.10.0"

## Space-separated list of spack-packages cherry-picks
read -r -d '' SPACKPACKAGES_CHERRYPICKS <<- \
--- || true
acac89d6bb7079412e711a50a3f06681132a2723
d4fb37cedfb7552a753bdc9c0c4792082f4b46e8
fa11df3be41f58bac19b73346422e06b103ee5b5
c322aa993ae106492bdb28333b56c5682a704027
9007ffd30a17fdb978b63fb55d7bca481031ca47
39191607781ae06888df8cc178f20cd762a0e806
---
## Optional hash table with comma-separated file list
## For these commits, the cherry-pick will be restricted to the listed files only.
## For all other commits, the cherry-pick will be applied without restriction (default).
read -r -d '' SPACKPACKAGES_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack-packages/commit/[hash]
## [hash]: [description]
## acac89d6bb7079412e711a50a3f06681132a2723: cuda: append --allow-unsupported-compiler to CUDAFLAGS for dependent_spec
## d4fb37cedfb7552a753bdc9c0c4792082f4b46e8: py-tensorflow: add libclang variant
## fa11df3be41f58bac19b73346422e06b103ee5b5: vecgeom: new versions 2.1.1, 2.2; celeritas: vecgeom@1.2:1 for @:0.6
## c322aa993ae106492bdb28333b56c5682a704027: celeritas: depends_on covfie ~cuda, vecgeom ~cuda (context for celeritas 0.7)
## 9007ffd30a17fdb978b63fb55d7bca481031ca47: celeritas: new version 0.7
## 39191607781ae06888df8cc178f20cd762a0e806: g4adept: add v0.3.5, v0.4.1
