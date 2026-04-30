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
