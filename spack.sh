## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
SPACK_VERSION="v0.22.2"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
09f75ee426a2e05e0543570821582480ff823ba5
f6d50f790ee8b123f7775429f6ca6394170e6de9
63f6e6079aacc99078386e5c8ff06173841b9595
092dc96e6c87a9c043e4421e1a524e23ec649f60
85f13442d2a7486daba81fdd9a3b6a1182ba11f6
f73d7d2dce226857cbc774e942454bad2992969e
cbab451c1a342523ed75e9be1098615a597a9b59
4fe5f35c2fff6288e4c05e5946798ad2191a2c40
4c60deb9921ff2cbbfa6771f4f63ff812a8a5840
b894acf1fca8eb5cc52d2267b0c4c187065998c0
8b45fa089e24c6ab7de2eaf614977369e69daa54
2d8ca8af6932dfd50204d1e4f6fe587dec7beef5
d3bf1e04fca844abb7c1eeac38dda4e126c81b67
81125c3bd80e71a2e57c7fcff8e02c4b3add5b90
8b2fec61f23a7b8230c0ed0378d90d04d8f590d8
2242da65fdc06e7ac04c43613dc7795164b3a7a3
1dc63dbea6c1d42aabf0e14b51439dcc46423e79
737b70cbbfacb3fba8054426e9b5bf8ede6d8faf
a66586d749197841bd74e289802126f2359287a8
7503a417731910d918a7863d1862f62c9b76429d
f8f01c336c882f29ac364995423b9f69ac365462
6051d56014730528da8dfa69934d93f9b7941a70
67536058077995cab1ed23b8ca62aaf75463ae04
7b9f8abce5cee74546a6f588f88c6f353170d52b
096ab11961995ac8d69f7b177cbcadf618d3068e
6c4abef75cb2b98c337f8a3179797e29dfdc9ca3
9cdb2a8dbb742169fefe0214ee76530e7f14dfdf
04f0af0a28e1f6ff0ef0b50e28ecf9d19fe544e6
395491815acb20e48050b77dca457aa7cc340ca1
43d1cdb0bd4780bff369dafa681a8a7939313784
5bc105c01c0e458924df40d51f7111ba507689f9
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
[67536058077995cab1ed23b8ca62aaf75463ae04]=var/spack/repos/builtin/packages/py-protobuf/package.py
[7b9f8abce5cee74546a6f588f88c6f353170d52b]=var/spack/repos/builtin/packages/protobuf/package.py,var/spack/repos/builtin/packages/py-protobuf/package.py
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## 09f75ee426a2e05e0543570821582480ff823ba5: setup-env.sh: if exe contains qemu, use /proc/$$/comm instead
## f6d50f790ee8b123f7775429f6ca6394170e6de9: gaudi: Add version 38.1
## 63f6e6079aacc99078386e5c8ff06173841b9595: gaudi: upstream patch when @38.1 for missing #include <list>
## 092dc96e6c87a9c043e4421e1a524e23ec649f60: acts: pass cuda_arch to CMAKE_CUDA_ARCHITECTURES
## 85f13442d2a7486daba81fdd9a3b6a1182ba11f6: Consolidate concretization output for environments
## f73d7d2dce226857cbc774e942454bad2992969e: dd4hep: cleanup recipe, remove deprecated versions and patches
## cbab451c1a342523ed75e9be1098615a597a9b59: dd4hep: Add version 1.29
## 4fe5f35c2fff6288e4c05e5946798ad2191a2c40: xrootd: add v5.7.0
## 4c60deb9921ff2cbbfa6771f4f63ff812a8a5840: xrootd: add github as secondary url to avoid SSL issues
## b894acf1fca8eb5cc52d2267b0c4c187065998c0: geant4: add v11.2.2, incl g4ndl v4.7.1
## 8b45fa089e24c6ab7de2eaf614977369e69daa54: geant4: support Qt5 and Qt6
## 2d8ca8af6932dfd50204d1e4f6fe587dec7beef5: qt-*: add v6.7.1, v6.7.2
## d3bf1e04fca844abb7c1eeac38dda4e126c81b67: py-vector: add through v1.4.1 (switch to hatchling)
## 81125c3bd80e71a2e57c7fcff8e02c4b3add5b90: hepmc3: pass root variant cxxstd as HEPMC3_CXX_STANDARD
## 8b2fec61f23a7b8230c0ed0378d90d04d8f590d8: hepmc3: add v3.3.0
## 2242da65fdc06e7ac04c43613dc7795164b3a7a3: graphviz: add through v12.1.0
## 1dc63dbea6c1d42aabf0e14b51439dcc46423e79: acts: add v34.1.0, v35.0.0 (identification, sycl variants changes)
## 737b70cbbfacb3fba8054426e9b5bf8ede6d8faf: Buildcache: remove deprecated --allow-root and preview subcommand
## a66586d749197841bd74e289802126f2359287a8: spack buildcache push: best effort
## 7503a417731910d918a7863d1862f62c9b76429d: cuda: add v12.4.1
## f8f01c336c882f29ac364995423b9f69ac365462: clang: support cxx20_flag and cxx23_flag
## 6051d56014730528da8dfa69934d93f9b7941a70: fastjet: avoid plugins=all,cxx combinations
## 67536058077995cab1ed23b8ca62aaf75463ae04: Update py-pyspark and py-py4j (py-protobuf only)
## 7b9f8abce5cee74546a6f588f88c6f353170d52b: Add depends_on([c,cxx,fortran])
## 096ab11961995ac8d69f7b177cbcadf618d3068e: py-onnx: link to external protobuf
## 6c4abef75cb2b98c337f8a3179797e29dfdc9ca3: py-protobuf: drop +cpp, always require protobuf
## 9cdb2a8dbb742169fefe0214ee76530e7f14dfdf: dd4hep: depends_on root +root7 in some cases
## 04f0af0a28e1f6ff0ef0b50e28ecf9d19fe544e6: acts,dd4hep: restrict to podio@0 to prevent failures with podio@1
## 395491815acb20e48050b77dca457aa7cc340ca1: dd4hep: mark conflict with root@6.31.1:
## 43d1cdb0bd4780bff369dafa681a8a7939313784: dd4hep: Add tag for version 1.30
## 5bc105c01c0e458924df40d51f7111ba507689f9: gfal2: new package (and dependencies)
