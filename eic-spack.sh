## EIC spack organization and repository, e.g. eic/eic-spack
EICSPACK_ORGREPO="eic/eic-spack"

## EIC spack commit hash or github version, e.g. v0.19.7
## note: nightly builds could use a branch e.g. releases/v0.19
EICSPACK_VERSION="33b156ce3c01b6c8c5b72107e26cb83b81b0f34c"

## Space-separated list of eic-spack cherry-picks
read -r -d '' EICSPACK_CHERRYPICKS <<- \
--- || true
---
## Ref: https://github.com/eic/eic-spack/commit/[hash]
## [hash]: [description]
