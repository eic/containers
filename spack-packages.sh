# shellcheck shell=bash
# shellcheck disable=SC2034  # Variables are used by scripts that source this file
## Spack organization and repository, e.g. spack/spack-packages
SPACKPACKAGES_ORGREPO="spack/spack-packages"

## Spack github version, e.g. v2025.07.0 or commit hash
## Note: nightly builds will use e.g. develop
## Note: when changing this, also make new buildcache public
## (default is only visible with internal authentication)
SPACKPACKAGES_VERSION="v2026.06.0"

## Space-separated list of spack-packages cherry-picks
read -r -d '' SPACKPACKAGES_CHERRYPICKS <<- \
--- || true
a115a811bdfce4db5298a9ba9b7903ccfb0de101
20444b8e9382e659360a1446688d10a8c2d2ad31
f5742718da7bd1d078ddc8423011a82ef2e3c759
deb4f17d93dbe012403614245334f7c73fcc086f
0d64b2bab72a99441f042b663e4bc993ec0db45d
a77a7ed0d2630466cac71165026387b1381b058a
403e4e0b2189600a736106bcfee568e31b5bcb22
88800eeac4ee97b7689b0a84d066e4f634f32b46
d8271eec35998674d3c67c7613b010fa98519df3
86e2acd247221d45f9944ac2f69518b8766baec3
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
## f5742718da7bd1d078ddc8423011a82ef2e3c759: gaudi: workaround test-dependency bug with a when
## deb4f17d93dbe012403614245334f7c73fcc086f: fix: add latest osg-ca-cert
## 0d64b2bab72a99441f042b663e4bc993ec0db45d: osg-ca-certs: depends on gmake and perl, type build
## a77a7ed0d2630466cac71165026387b1381b058a: py-pynacl: depends on gmake, type build
## 403e4e0b2189600a736106bcfee568e31b5bcb22: py-rucio-clients: add 40.2.0
## 88800eeac4ee97b7689b0a84d066e4f634f32b46: py-boto3: add v1.42.85 and py-botocore: add v1.42.85
## d8271eec35998674d3c67c7613b010fa98519df3: py-setuptools-scm: Earlier versions require setuptools-scm too
## 86e2acd247221d45f9944ac2f69518b8766baec3: py-boto3: add v1.43.17, updated dependencies
