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
69b17ea6024b1f9ef39681f1aba3a499e54f58eb
6a217dc5d327de87441ebec89c43818bf8fe2746
00f179ee6da8252dff882c2d2249240f2d43805a
94cf51875f0e29b79c2a1bd69e0fcddac3eec0c8
a86953fcb14a1e6ab760cba6957850ecfd40cca7
6b16c64c0e11ed6bd3605b15811f111f44800d97
49efa711d04049d48690231ac9b1ccb81cc4d448
e94d5b935f9da408371059cf0fd9001108f24772
af9fd82476b8e9ab5d04b250ac3dbc3e8cde3291
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
## 69b17ea6024b1f9ef39681f1aba3a499e54f58eb: py-paramiko: add v3.3.2, v3.4.1, v3.5.0
## 6a217dc5d327de87441ebec89c43818bf8fe2746: gsoap: depends_on autoconf etc type build
## 00f179ee6da8252dff882c2d2249240f2d43805a: root: add v6.32.08
## 94cf51875f0e29b79c2a1bd69e0fcddac3eec0c8: acts: don't use system dfelibs for 35.1:36.0
## a86953fcb14a1e6ab760cba6957850ecfd40cca7: acts: add version 37.4.0
## 6b16c64c0e11ed6bd3605b15811f111f44800d97: acts dependencies: new versions as of 2024/12/02
## 49efa711d04049d48690231ac9b1ccb81cc4d448: acts dependencies: new versions as of 2024/12/08
## e94d5b935f9da408371059cf0fd9001108f24772: acts dependencies: new versions as of 2025/01/08
## af9fd82476b8e9ab5d04b250ac3dbc3e8cde3291: acts: conflict ~svg ~json when +traccc