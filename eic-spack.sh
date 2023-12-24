## EIC spack organization and repository, e.g. eic/eic-spack
EICSPACK_ORGREPO="eic/eic-spack"

## EIC spack commit hash or github version, e.g. v0.19.7
## note: nightly builds could use a branch e.g. releases/v0.19
EICSPACK_VERSION="5d8ba97ea6b021a50aa11e924a55a4726c689d65"

## Space-separated list of eic-spack cherry-picks
read -r -d '' EICSPACK_CHERRYPICKS <<- \
--- || true
---
## Ref: https://github.com/eic/eic-spack/commit/[hash]
## [hash]: [description]
