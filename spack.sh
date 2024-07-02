## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
SPACK_VERSION="v0.22.0"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
09f75ee426a2e05e0543570821582480ff823ba5
f6d50f790ee8b123f7775429f6ca6394170e6de9
63f6e6079aacc99078386e5c8ff06173841b9595
9bcc43c4c158639fa6cb575c6106595a34682081
85f13442d2a7486daba81fdd9a3b6a1182ba11f6
f73d7d2dce226857cbc774e942454bad2992969e
cbab451c1a342523ed75e9be1098615a597a9b59
092dc96e6c87a9c043e4421e1a524e23ec649f60
1dc63dbea6c1d42aabf0e14b51439dcc46423e79
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## 09f75ee426a2e05e0543570821582480ff823ba5: setup-env.sh: if exe contains qemu, use /proc/$$/comm instead
## f6d50f790ee8b123f7775429f6ca6394170e6de9: gaudi: Add version 38.1
## 63f6e6079aacc99078386e5c8ff06173841b9595: gaudi: upstream patch when @38.1 for missing #include <list>
## 9bcc43c4c158639fa6cb575c6106595a34682081: protobuf: update hash for patch needed when="@3.4:3.21"
## 85f13442d2a7486daba81fdd9a3b6a1182ba11f6: Consolidate concretization output for environments
## f73d7d2dce226857cbc774e942454bad2992969e: dd4hep: cleanup recipe, remove deprecated versions and patches
## cbab451c1a342523ed75e9be1098615a597a9b59: dd4hep: Add version 1.29
## 092dc96e6c87a9c043e4421e1a524e23ec649f60: acts: pass cuda_arch to CMAKE_CUDA_ARCHITECTURES
## 1dc63dbea6c1d42aabf0e14b51439dcc46423e79: acts: add v34.1.0, v35.0.0 (identification, sycl variants changes)
