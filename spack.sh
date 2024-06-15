## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
SPACK_VERSION="v0.22.0"

## Array of spack cherry-picks
read -r -d '' -a SPACK_CHERRYPICKS <<- \
--- || true
09f75ee426a2e05e0543570821582480ff823ba5
f6d50f790ee8b123f7775429f6ca6394170e6de9
63f6e6079aacc99078386e5c8ff06173841b9595
9bcc43c4c158639fa6cb575c6106595a34682081
9f3e45ddbee24aaa7993e575297827e0aed2e6fe
---
## Optional hash table with comma-separated file list
read -r -d '' -a SPACK_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## 09f75ee426a2e05e0543570821582480ff823ba5: setup-env.sh: if exe contains qemu, use /proc/$$/comm instead
## f6d50f790ee8b123f7775429f6ca6394170e6de9: gaudi: Add version 38.1
## 63f6e6079aacc99078386e5c8ff06173841b9595: gaudi: upstream patch when @38.1 for missing #include <list>
## 9bcc43c4c158639fa6cb575c6106595a34682081: protobuf: update hash for patch needed when="@3.4:3.21"
## 9f3e45ddbee24aaa7993e575297827e0aed2e6fe: acts: pass cuda_arch to CMAKE_CUDA_ARCHITECTURES
