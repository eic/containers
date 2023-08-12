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
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
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
