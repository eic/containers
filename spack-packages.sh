# shellcheck shell=bash
# shellcheck disable=SC2034  # Variables are used by scripts that source this file
## Spack organization and repository, e.g. spack/spack-packages
SPACKPACKAGES_ORGREPO="spack/spack-packages"

## Spack github version, e.g. v2025.07.0 or commit hash
## Note: nightly builds will use e.g. develop
## Note: when changing this, also make new buildcache public
## (default is only visible with internal authentication)
SPACKPACKAGES_VERSION="v2026.03.0"

## Space-separated list of spack-packages cherry-picks
read -r -d '' SPACKPACKAGES_CHERRYPICKS <<- \
--- || true
a115a811bdfce4db5298a9ba9b7903ccfb0de101
20444b8e9382e659360a1446688d10a8c2d2ad31
5c37f836753e8f9683fdc547f3661c5045abcbd1
f5742718da7bd1d078ddc8423011a82ef2e3c759
0d4e42deee0f561013568d1e92205a084cf203bc
6346a54e35ee6281b8e8c6a1bc9c102893593c8e
f0ff58aff997ab3c4c0598e0ccdfd662a06d1233
bd32638d817fa66188880e557196acd2a5d6e7b6
b17f3abec760256ad7faf1b1d102f2553d6a3622
45f50975f023b3a444217e3d474c2b2d264763b3
6b86b44735775c97636861dd66ee14ce83906422
7f9f7ff5c232068aec8ff30b147a098dd25d9ef9
346babf5aebcf03045fbe10e59750fac8c95947f
2c49a2c6a2f8a95c25e0add0e8fc67d1a5351f96
107eb9966c8a9688e042c42e903274099688b590
cfdc775b857dbecc1b7ba62b5ec00d4f8b0f3e6b
045873c8cbce3eef07ed068a998467e01bd91129
b11529d6bbd8abc9f7bde6faf290b1c22385a022
9d1b52d36a4c89d9c3964f599cd00232b901e9ac
deb4f17d93dbe012403614245334f7c73fcc086f
0d64b2bab72a99441f042b663e4bc993ec0db45d
a77a7ed0d2630466cac71165026387b1381b058a
403e4e0b2189600a736106bcfee568e31b5bcb22
88800eeac4ee97b7689b0a84d066e4f634f32b46
d8271eec35998674d3c67c7613b010fa98519df3
86e2acd247221d45f9944ac2f69518b8766baec3
8cd9959e3fd4e54d79bbf75210e335ab842e1af0
---
## Optional hash table with comma-separated file list
## For these commits, the cherry-pick will be restricted to the listed files only.
## For all other commits, the cherry-pick will be applied without restriction (default).
read -r -d '' SPACKPACKAGES_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack-packages/commit/[hash]
## [hash]: [description]
## a115a811bdfce4db5298a9ba9b7903ccfb0de101: github-copilot: new package
## 20444b8e9382e659360a1446688d10a8c2d2ad31: github-copilot: add v1.0.8
## 5c37f836753e8f9683fdc547f3661c5045abcbd1: root: require openblas ~ilp64 symbol_suffix=none when ^openblas
## f5742718da7bd1d078ddc8423011a82ef2e3c759: gaudi: workaround test-dependency bug with a when
## 0d4e42deee0f561013568d1e92205a084cf203bc: g4hepem: new package
## 6346a54e35ee6281b8e8c6a1bc9c102893593c8e: g4adept: new package
## f0ff58aff997ab3c4c0598e0ccdfd662a06d1233: py-tf2onnx: add v1.17.0 (new package)
## bd32638d817fa66188880e557196acd2a5d6e7b6: py-tf2onnx: depends on py-tensorflow
## b17f3abec760256ad7faf1b1d102f2553d6a3622: (py-)protobuf: add v(5.)28.3
## 45f50975f023b3a444217e3d474c2b2d264763b3: py-torch: patch for GCC-14.2 ICE on aarch64
## 6b86b44735775c97636861dd66ee14ce83906422: apfelxx, epic, partons*, sfml: new packages
## 7f9f7ff5c232068aec8ff30b147a098dd25d9ef9: pelican: new package, v7.24.3
## 346babf5aebcf03045fbe10e59750fac8c95947f: py-mplhep(-data): add new versions
## 2c49a2c6a2f8a95c25e0add0e8fc67d1a5351f96: py-awkward, py-uproot, py-uhi ecosystem (HEP): add new versions
## 107eb9966c8a9688e042c42e903274099688b590: dd4hep: add v1.36
## cfdc775b857dbecc1b7ba62b5ec00d4f8b0f3e6b: dd4hep: add v1.37
## 045873c8cbce3eef07ed068a998467e01bd91129: py-snakemake-storage-plugin-pelican: new package v0.1.1 + deps
## b11529d6bbd8abc9f7bde6faf290b1c22385a022: py-onnxruntime: only run tests when self.run_tests
## 9d1b52d36a4c89d9c3964f599cd00232b901e9ac: julia: avoid cascading mbedtls in v1.12+
## deb4f17d93dbe012403614245334f7c73fcc086f: fix: add latest osg-ca-cert
## 0d64b2bab72a99441f042b663e4bc993ec0db45d: osg-ca-certs: depends on gmake and perl, type build
## a77a7ed0d2630466cac71165026387b1381b058a: py-pynacl: depends on gmake, type build
## 403e4e0b2189600a736106bcfee568e31b5bcb22: py-rucio-clients: add 40.2.0
## 88800eeac4ee97b7689b0a84d066e4f634f32b46: py-boto3: add v1.42.85 and py-botocore: add v1.42.85
## d8271eec35998674d3c67c7613b010fa98519df3: py-setuptools-scm: Earlier versions require setuptools-scm too
## 86e2acd247221d45f9944ac2f69518b8766baec3: py-boto3: add v1.43.17, updated dependencies
## 8cd9959e3fd4e54d79bbf75210e335ab842e1af0: root: add builtin_llvm variant to allow external LLVM
