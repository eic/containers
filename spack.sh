## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
SPACK_VERSION="v0.23.0"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
09f75ee426a2e05e0543570821582480ff823ba5
b90ac6441cfdf6425cb59551e7b0538899b69527
8e7641e584563c4859cbef992cd534e75ffd8142
c50ac5ac25619bdf0b3e75884a893a73e5713e05
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## 09f75ee426a2e05e0543570821582480ff823ba5: setup-env.sh: if exe contains qemu, use /proc/$$/comm instead
## b90ac6441cfdf6425cb59551e7b0538899b69527: celeritas: remove ancient versions and add CUDA package dependency
## 8e7641e584563c4859cbef992cd534e75ffd8142: onnx: set CMAKE_CXX_STANDARD to abseil-cpp cxxstd value
## c50ac5ac25619bdf0b3e75884a893a73e5713e05: py-gfal2-python: new package to fix gfal2-util
