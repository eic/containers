## EIC spack organization and repository, e.g. eic/eic-spack
EICSPACK_ORGREPO="eic/eic-spack"

## EIC spack commit hash or github version, e.g. v0.19.7
## note: nightly builds could use a branch e.g. releases/v0.19
EICSPACK_VERSION="ad33251135b154690a0bf408e81dda293a0097e0"

## Space-separated list of eic-spack cherry-picks
read -r -d '' EICSPACK_CHERRYPICKS <<- \
--- || true
---
## Ref: https://github.com/eic/eic-spack/commit/[hash]
## [hash]: [description]
