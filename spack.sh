## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
SPACK_VERSION="v0.23.1"

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
3dcbd118df52e1bb93aba59c1751e448ee6a9358
c57452dd08f9f4da6db1f4591053ea496893140a
e1dfbbf611ee9ed23f51c6a7629ca2584a42d0af
75b03bc12ffbabdfac0775ead5442c3f102f94c7
e56057fd795d30146d58934840fe5b6e96f71e65
1148c8f195d812e5bd586f404edd403579ed5df2
9d07efa0dc6e7ebd715487be5e0092a608964cf0
4d6347c99c5fb76d374baa5f933ab5bbae32793a
396a70186002764891e2ae597ecefd02617570dd
ebb3736de79e6e119a0057788a6b906507cb166f
3c64821c6445aa085848ecb19482ebddeea7b657
8f145f5e8ed98c0a5dcc0c0bea7b441bc0433923
8196c68ff33dcde4f82df7063f6adf50fbe808d3
b2a86fcaba3397e912eec32a7059e26ab234cef7
a86953fcb14a1e6ab760cba6957850ecfd40cca7
6b16c64c0e11ed6bd3605b15811f111f44800d97
49efa711d04049d48690231ac9b1ccb81cc4d448
e94d5b935f9da408371059cf0fd9001108f24772
af9fd82476b8e9ab5d04b250ac3dbc3e8cde3291
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
[396a70186002764891e2ae597ecefd02617570dd]=var/spack/repos/builtin/packages/node-js/package.py
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
## 3dcbd118df52e1bb93aba59c1751e448ee6a9358: py-cython: support Python 3.12+
## c57452dd08f9f4da6db1f4591053ea496893140a: py-cffi: support Python 3.12+
## e1dfbbf611ee9ed23f51c6a7629ca2584a42d0af: py-greenlet: add v3.0.3, v3.1.1
## 75b03bc12ffbabdfac0775ead5442c3f102f94c7: glib: add v2.82.2
## e56057fd795d30146d58934840fe5b6e96f71e65: gobject-introspection: Do not write to user home
## 1148c8f195d812e5bd586f404edd403579ed5df2: gobject-introspection: Python 3.12 still not supported
## 9d07efa0dc6e7ebd715487be5e0092a608964cf0: gobject-introspection: patch to import setuptools before distutils
## 4d6347c99c5fb76d374baa5f933ab5bbae32793a: node-js: patch for %gcc@12.[1-2] when @22.2:22
## 396a70186002764891e2ae597ecefd02617570dd: python: deprecate 3.8
## ebb3736de79e6e119a0057788a6b906507cb166f: node-js: update to 22.11.0
## 3c64821c6445aa085848ecb19482ebddeea7b657: node-js: less strict python requirement for newer versions of node-js
## 8f145f5e8ed98c0a5dcc0c0bea7b441bc0433923: node-js: always depend on some python, regardless of lower/upper limits
## 8196c68ff33dcde4f82df7063f6adf50fbe808d3: py-dask: fix py-versioneer version pin
## b2a86fcaba3397e912eec32a7059e26ab234cef7: py-plac: add v1.4.3; restrict to python@:3.11 for older
## a86953fcb14a1e6ab760cba6957850ecfd40cca7: acts: add version 37.4.0
## 6b16c64c0e11ed6bd3605b15811f111f44800d97: acts dependencies: new versions as of 2024/12/02
## 49efa711d04049d48690231ac9b1ccb81cc4d448: acts dependencies: new versions as of 2024/12/08
## e94d5b935f9da408371059cf0fd9001108f24772: acts dependencies: new versions as of 2025/01/08
## af9fd82476b8e9ab5d04b250ac3dbc3e8cde3291: acts: conflict ~svg ~json when +traccc