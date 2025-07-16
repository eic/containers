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
d5c0ace993d2b495de549e6694081b8e9baf2cfb
0db3b36874457e065fb49ec469a40e72d6c011a0
f2f13964fbb0d29a74f605e31b20f724d88cc024
0ce38ed1092aefeccb31ffed8e23e8d3ef58a4b1
5640861aebbf3a56715ce0e311ffb365872a8a4d
21d5fd6ec1279a92022bc388294d9a76881e43f3
39c10c31169478b464cbfb50d12c865cf763790f
8487842e11e4057c0ec0cc53049a94740f1f8466
b02340724d43313377e7fa1e48e9fe9ac362bd49
a14f10e8825fd25e0615095feaa548b1938fffac
e76f8fda2d959fdf7a262eb539a4002a6a0c900f
7e89b3521ae8c9fb4ef3e94748d170ba1b799bf2
c0c1a4aea1aa38bd7054cbac2e3fa1606f6939e9
71b65bb424c6294badc4825ac4714ec7f89ad0b7
a7e57c9a14ce36d6a3b03d7cd3b3357754b89019
6b9c099af871e7cfc48d831aaefd542064f8dafa
406c73ae1152b0f66b299fab2973d3b25dee8118
2b9434a3401a5ce16ac056cd7309078bde6a86a5
f5e84fb9e73f6230576c01673563b5ddbd529e90
38e9043b9e3c0c5ebe9f98ca7cf8f0fe26a05e9d
a86953fcb14a1e6ab760cba6957850ecfd40cca7
6b16c64c0e11ed6bd3605b15811f111f44800d97
49efa711d04049d48690231ac9b1ccb81cc4d448
72ef5b90102d52d0994b9104bbc96011757c946e
94cf51875f0e29b79c2a1bd69e0fcddac3eec0c8
e94d5b935f9da408371059cf0fd9001108f24772
af9fd82476b8e9ab5d04b250ac3dbc3e8cde3291
495537cf56df07950a436d841a6ab1e114f06ac5
e94d5b935f9da408371059cf0fd9001108f24772
615b7a6ddb35b11ff149ab0efe66f6817ed0aa53
f7edd10c17e097db2f3a4aff16341ca507184b2d
46ff553ec2a5119e0d88fd21858c59205889b8ee
b2b9914efc6ba15a4b56341da1515642a5614275
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
[396a70186002764891e2ae597ecefd02617570dd]=var/spack/repos/builtin/packages/node-js/package.py
[f2f13964fbb0d29a74f605e31b20f724d88cc024]=var/spack/repos/builtin/packages/sherpa/package.py
[38e9043b9e3c0c5ebe9f98ca7cf8f0fe26a05e9d]=var/spack/repos/builtin/packages/rivet/package.py,var/spack/repos/builtin/packages/yoda/package.py
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
## d5c0ace993d2b495de549e6694081b8e9baf2cfb: simsipm: add a new version and a variant for setting the C++ standard
## 0db3b36874457e065fb49ec469a40e72d6c011a0: sherpa: fix AutotoolsBuilder install signature
## f2f13964fbb0d29a74f605e31b20f724d88cc024: sherpa: support cxxstd=20 when=@3:
## 0ce38ed1092aefeccb31ffed8e23e8d3ef58a4b1: rivet: patch to fix missing headers
## 5640861aebbf3a56715ce0e311ffb365872a8a4d: Improve package recipes for some HEP packages
## 21d5fd6ec1279a92022bc388294d9a76881e43f3: dd4hep: Fix faulty package configuration
## 39c10c31169478b464cbfb50d12c865cf763790f: dd4hep: add v1.31
## 8487842e11e4057c0ec0cc53049a94740f1f8466: gaudi: add v39.1; patch for failing test; properly support +examples
## b02340724d43313377e7fa1e48e9fe9ac362bd49: gaudi: Fix nonexistent 'libs'
## a14f10e8825fd25e0615095feaa548b1938fffac: openloops: Fix configuration of cmodel setting for gfortran
## e76f8fda2d959fdf7a262eb539a4002a6a0c900f: openloops: use cmodel small on aarch64 instead of large
## 7e89b3521ae8c9fb4ef3e94748d170ba1b799bf2: openloops: add v2.1.3, v2.1.4
## c0c1a4aea1aa38bd7054cbac2e3fa1606f6939e9: podio: add v1.2; conflicts +rntuple ^root@6.32: when @:0.99
## 71b65bb424c6294badc4825ac4714ec7f89ad0b7: py-opt-einsum: missing forward compat bound for python
## a7e57c9a14ce36d6a3b03d7cd3b3357754b89019: py-opt-einsum: add v3.4.0
## 6b9c099af871e7cfc48d831aaefd542064f8dafa: py-keras: add v3.7.0
## 406c73ae1152b0f66b299fab2973d3b25dee8118: py-boto*: add v1.34.162
## 2b9434a3401a5ce16ac056cd7309078bde6a86a5: rivet, yoda: Add new versions with back-port fixes
## f5e84fb9e73f6230576c01673563b5ddbd529e90: rivet: patch missing header in 3.1.10
## 38e9043b9e3c0c5ebe9f98ca7cf8f0fe26a05e9d: yoda: add v2.1.0; rivet: add v4.1.0
## a86953fcb14a1e6ab760cba6957850ecfd40cca7: acts: add version 37.4.0
## 6b16c64c0e11ed6bd3605b15811f111f44800d97: acts dependencies: new versions as of 2024/12/02
## 49efa711d04049d48690231ac9b1ccb81cc4d448: acts dependencies: new versions as of 2024/12/08
## 72ef5b90102d52d0994b9104bbc96011757c946e: acts dependencies: new versions as of 2024/12/16
## 94cf51875f0e29b79c2a1bd69e0fcddac3eec0c8: acts: don't use system dfelibs for 35.1:36.0
## e94d5b935f9da408371059cf0fd9001108f24772: acts dependencies: new versions as of 2025/01/08
## af9fd82476b8e9ab5d04b250ac3dbc3e8cde3291: acts: conflict ~svg ~json when +traccc
## 495537cf56df07950a436d841a6ab1e114f06ac5: acts: add v39.0.0
## e94d5b935f9da408371059cf0fd9001108f24772: acts dependencies: new versions as of 2025/01/08
## 615b7a6ddb35b11ff149ab0efe66f6817ed0aa53: geomodel: Add version 6.8.0
## f7edd10c17e097db2f3a4aff16341ca507184b2d: acts dependencies: new versions as of 2025/02/10
## 46ff553ec2a5119e0d88fd21858c59205889b8ee: acts dependencies: new versions as of 2025/02/17
## b2b9914efc6ba15a4b56341da1515642a5614275: acts dependencies: new versions as of 2025/03/03