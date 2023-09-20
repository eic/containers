## EIC spack organization and repository, e.g. eic/eic-spack
EICSPACK_ORGREPO="eic/eic-spack"

## EIC spack github version, e.g. v0.19.7 or commit hash
## note: nightly builds will use e.g. releases/v0.19
EICSPACK_VERSION="v0.20.18"

## Space-separated list of eic-spack cherry-picks
read -r -d '' EICSPACK_CHERRYPICKS <<- \
--- || true
e976b3790a2fe6193d58484c473110bc8d089ee4
3913a77446e4318962e546eb3159e7127967c860
53064865f6fd44035ba0286cd09b0990dc3ddd08
0969ee98ed9043ac29af2f832a00ee0f3eb87bff
63433a2a8686d5cb7d2fcc6a96471e6c92ce4a38
---
## Ref: https://github.com/eic/eic-spack/commit/[hash]
## [hash]: [description]
