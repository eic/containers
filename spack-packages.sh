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
5c37f836753e8f9683fdc547f3661c5045abcbd1
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
## 5c37f836753e8f9683fdc547f3661c5045abcbd1: root: require openblas ~ilp64 symbol_suffix=none when ^openblas
