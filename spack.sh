## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
SPACK_VERSION="v0.20.1"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
ef5d110d4abd2411d6bde82d738b205eb6672fe8
9ee2d79de172de14477a78e5d407548a63eea33a
776ab132760d63eab0703b7c0ebebc72a8443f5b
188168c476eabe99764634db8d78eb3f9ea2a927
b3268c2703b84f4e4961c1e2cdf43e8998f283e6
4ae1a73d54b33bc4876535422d3f3bf3d9641c51
9e4c4be3f523a0d144870dbf5645ad7bf0ff04be
d8a9b42da6cdef3a08ec48931bf282e5e4811d38
ce0b9ea8cf184c9048cac1ae88f2d69f0e4520c7
ea1439dfa11a3996c9927ed792dc9fe4b7efc1b8
5996aaa4e3b8b37f847da356489bb27958b968f1
31431f967a59c07585021cba40683c2ca6ff2c47
316bfd8b7d0d1bc63a7bccf030845775a442a317
6e47f1645f31ce598d7f1f9770e24b483fb117d9
63bb2c9bad8acb018f220630e5ce58e4a039d8a2
ed76eab6943221f17776fd8d128ade6ba69e492c
6c5d125cb06a86ce05bec27ae9fb9b07103bc1c5
e3e7609af4903be7df42b6ae5ccf9a20293503d2
df4a2457a41e7ab634e86d3148d8b22a9f433a6a
53a45c820c983867e8b05cab3df34e98b468f932
dca3d071d778cb7ca85166028acb5b866124157c
c17fc3c0c1ecbebcfbf57214bf2724e26e6e1883
ef4b35ea6361e83b243b375fc4e2a28cfc25bc8f
36dd3251876895167270e26b14d16181895d6ace
518da168331fd0e58c6c3a611b52507d1750b13a
5ba4a2b83a0fabbfd221328a3c96955e9395b6ca
eea743de461feca88fabf8c87e8fe617a368250c
29835ac3437a7f975f7fdd22fac864b3273ff7d5
581f45b63908dda8429b63c32047fd5295a95507
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## ef5d110d4abd2411d6bde82d738b205eb6672fe8: Fix multiple quadratic complexity issues in environments
## 9ee2d79de172de14477a78e5d407548a63eea33a: libxpm package: fix RHEL8 build with libintl
## 776ab132760d63eab0703b7c0ebebc72a8443f5b: [xrootd] New variants, new version, improve build config
## 188168c476eabe99764634db8d78eb3f9ea2a927: podio: Add 0.16.5 tag
## b3268c2703b84f4e4961c1e2cdf43e8998f283e6: freetype: add pic and shared variants
## 4ae1a73d54b33bc4876535422d3f3bf3d9641c51: (r-rcpp)ensmallen: new package
## 9e4c4be3f523a0d144870dbf5645ad7bf0ff04be: mlpack: new package
## d8a9b42da6cdef3a08ec48931bf282e5e4811d38: actsvg: add v0.4.33
## ce0b9ea8cf184c9048cac1ae88f2d69f0e4520c7: acts: ensure Python_EXECUTABLE uses ^python when +python
## ea1439dfa11a3996c9927ed792dc9fe4b7efc1b8: acts: new variant cxxstd
## 5996aaa4e3b8b37f847da356489bb27958b968f1: acts: new versions 23.[3-5].0, 24.0.0, 25.0.[0-1], 26.0.0, 27.[0-1].0, 28.0.0
## 31431f967a59c07585021cba40683c2ca6ff2c47: Environment/depfile: fix bug with Git hash versions
## 316bfd8b7d0d1bc63a7bccf030845775a442a317: opencascade: new variants
## 6e47f1645f31ce598d7f1f9770e24b483fb117d9: opencascade: typo in True
## 63bb2c9bad8acb018f220630e5ce58e4a039d8a2: py-cryptography: does not run-depend on py-setuptools-rust
## ed76eab6943221f17776fd8d128ade6ba69e492c: geant4: new version 11.1.2
## 6c5d125cb06a86ce05bec27ae9fb9b07103bc1c5: cernlib: new variant shared
## e3e7609af4903be7df42b6ae5ccf9a20293503d2: edm4hep: Add version 0.9
## df4a2457a41e7ab634e86d3148d8b22a9f433a6a: Fix broken semver regex
## 53a45c820c983867e8b05cab3df34e98b468f932: docker entrypoint.sh: fail multi-line RUN on first error with set -e
## dca3d071d778cb7ca85166028acb5b866124157c: gaudi: fix issue with fmt::format
## c17fc3c0c1ecbebcfbf57214bf2724e26e6e1883: gaudi: add gaudi to LD_LIBRARY_PATH
## ef4b35ea6361e83b243b375fc4e2a28cfc25bc8f: gaudi: remove the py-qmtest dependency
## 36dd3251876895167270e26b14d16181895d6ace: gaudi: new versions 36.[11-14]
## // e51748ee8f89e0d3db4e426e3d04157129a45622: zlib-api: new virtual with zlib/zlib-ng as providers
## 518da168331fd0e58c6c3a611b52507d1750b13a: Gaudi: Add a few versions and a dependency on tbb after 37.1
## 5ba4a2b83a0fabbfd221328a3c96955e9395b6ca: podio: bump minimal version of catch2
## eea743de461feca88fabf8c87e8fe617a368250c: podio: Add py-tabulate as new run and test dependency
## 29835ac3437a7f975f7fdd22fac864b3273ff7d5: podio: add 0.16.6 tag and mark older releases as deprecated
## 581f45b63908dda8429b63c32047fd5295a95507: podio: Add latest tags and variants and update dependencies accordingly
