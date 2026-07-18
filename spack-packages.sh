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
82a6d07a37d13c247e84417055f9cb5b4802ac4f
47780b2c59a8356c1f13cd7c8d250e3250c15ba8
28bd1a044251fca35e14ba55d7ddb567deadcdaa
a7c32f24cd5b69b237dc974804a71326306f4e58
de97f131df3dbc940151f406afd5c2c1158a660c
caf013be0ee1594fdbba8feb07ffecc88474a2b0
75395349957ad785cca50002dffb18bbcb48af27
d8ed806a90f06527e5d1b231b45fc6f60b576317
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
## 82a6d07a37d13c247e84417055f9cb5b4802ac4f: osg-ca-certs: depends on gmake and perl, type build
## 47780b2c59a8356c1f13cd7c8d250e3250c15ba8: py-pynacl: depends on gmake, type build
## 28bd1a044251fca35e14ba55d7ddb567deadcdaa: py-throttler: add v1.2.3
## a7c32f24cd5b69b237dc974804a71326306f4e58: py-tensorboard: add v2.21.0
## de97f131df3dbc940151f406afd5c2c1158a660c: TensorFlow: add v2.21.0
## caf013be0ee1594fdbba8feb07ffecc88474a2b0: Add missing xxd dep
## 75395349957ad785cca50002dffb18bbcb48af27: py-torch: ensure setuptools is not unnecessarily constrained for 2.10:
## d8ed806a90f06527e5d1b231b45fc6f60b576317: cargo-c: depends_on pkgconfig
