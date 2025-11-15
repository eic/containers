## Spack organization and repository, e.g. spack/spack-packages
SPACKPACKAGES_ORGREPO="spack/spack-packages"

## Spack github version, e.g. v2025.07.0 or commit hash
## note: nightly builds will use e.g. develop
SPACKPACKAGES_VERSION="v2025.11.0"

## Space-separated list of spack-packages cherry-picks
read -r -d '' SPACKPACKAGES_CHERRYPICKS <<- \
--- || true
a115a811bdfce4db5298a9ba9b7903ccfb0de101
22dadd619053ff0872903549db616200bda082f0
559789f67245a40306aeea636b61348e97d4f092
95c45b6c3322e151fd29ed00ea10567b97705ee4
d6f99b8d611cf740eb45e13df2c84044a4ca6ae4
bc25e5eb2f8f7a8733cdc10d92e9787358c82cfa
c4d983b764d7b1ee2b63da79f5f25365ac61ce7a
44da889cc86bb8a5315c729a7c79f2c002c9c951
5c37f836753e8f9683fdc547f3661c5045abcbd1
c75e10845431600b163c597545bd099e427c62f5
438a7d95de1b81e15107edbf341b20824ec80635
---
## Optional hash table with comma-separated file list
read -r -d '' SPACKPACKAGES_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack-packages/commit/[hash]
## [hash]: [description]
## a115a811bdfce4db5298a9ba9b7903ccfb0de101: github-copilot: new package
## 22dadd619053ff0872903549db616200bda082f0: claude-code: new package
## 559789f67245a40306aeea636b61348e97d4f092: estarlight: add thru v1.2.0
## 95c45b6c3322e151fd29ed00ea10567b97705ee4: py-tensorflow: modify cuDNN dependency versions when +cuda
## d6f99b8d611cf740eb45e13df2c84044a4ca6ae4: py-tensorflow: patch to build with +cuda
## bc25e5eb2f8f7a8733cdc10d92e9787358c82cfa: actsvg: patch version numbers into source source
## c4d983b764d7b1ee2b63da79f5f25365ac61ce7a: Julia: add v1.11.6
## 44da889cc86bb8a5315c729a7c79f2c002c9c951: Julia: add v1.11.7
## 5c37f836753e8f9683fdc547f3661c5045abcbd1: root: require openblas ~ilp64 symbol_suffix=none when ^openblas
## c75e10845431600b163c597545bd099e427c62f5: dd4hep: v1.33
## 438a7d95de1b81e15107edbf341b20824ec80635: root: add v6.36.06
