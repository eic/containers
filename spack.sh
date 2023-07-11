## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
SPACK_VERSION="v0.20.1"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
9ee2d79de172de14477a78e5d407548a63eea33a
776ab132760d63eab0703b7c0ebebc72a8443f5b
188168c476eabe99764634db8d78eb3f9ea2a927
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## 9ee2d79de172de14477a78e5d407548a63eea33a: libxpm package: fix RHEL8 build with libintl
## 776ab132760d63eab0703b7c0ebebc72a8443f5b: [xrootd] New variants, new version, improve build config
## 188168c476eabe99764634db8d78eb3f9ea2a927: podio: Add 0.16.5 tag
