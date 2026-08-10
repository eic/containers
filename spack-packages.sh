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
384fd54caf18c6393607bff018853747d02c6e0f
bd9b4838fbf9e4ca01ad7b6c6df633ddcc750d71
deb4f17d93dbe012403614245334f7c73fcc086f
82a6d07a37d13c247e84417055f9cb5b4802ac4f
47780b2c59a8356c1f13cd7c8d250e3250c15ba8
28bd1a044251fca35e14ba55d7ddb567deadcdaa
72269859719d77f986be7cc752946650d020ac3f
de97f131df3dbc940151f406afd5c2c1158a660c
caf013be0ee1594fdbba8feb07ffecc88474a2b0
75395349957ad785cca50002dffb18bbcb48af27
acac89d6bb7079412e711a50a3f06681132a2723
438abd1e09f0cea9cb0ccc7e0326adcd0408196b
d4fb37cedfb7552a753bdc9c0c4792082f4b46e8
4dc856a13e9066ca3249a593d351af8cda521fa3
3dcad5bb860184c91c17b97a9f3b13252d26d309
---
## Optional hash table with comma-separated file list
## For these commits, the cherry-pick will be restricted to the listed files only.
## For all other commits, the cherry-pick will be applied without restriction (default).
read -r -d '' SPACKPACKAGES_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack-packages/commit/[hash]
## [hash]: [description]
## 384fd54caf18c6393607bff018853747d02c6e0f: github-copilot: new package
## bd9b4838fbf9e4ca01ad7b6c6df633ddcc750d71: gaudi: workaround test-dependency bug with a when
## deb4f17d93dbe012403614245334f7c73fcc086f: fix: add latest osg-ca-cert
## 82a6d07a37d13c247e84417055f9cb5b4802ac4f: osg-ca-certs: depends on gmake and perl, type build
## 47780b2c59a8356c1f13cd7c8d250e3250c15ba8: py-pynacl: depends on gmake, type build
## 28bd1a044251fca35e14ba55d7ddb567deadcdaa: py-throttler: add v1.2.3
## 72269859719d77f986be7cc752946650d020ac3f: py-tensorboard: add v2.21.0
## de97f131df3dbc940151f406afd5c2c1158a660c: TensorFlow: add v2.21.0
## caf013be0ee1594fdbba8feb07ffecc88474a2b0: Add missing xxd dep
## 75395349957ad785cca50002dffb18bbcb48af27: py-torch: ensure setuptools is not unnecessarily constrained for 2.10:
## acac89d6bb7079412e711a50a3f06681132a2723: cuda: append --allow-unsupported-compiler to CUDAFLAGS for dependent_spec
## 438abd1e09f0cea9cb0ccc7e0326adcd0408196b: herwig3: add CT14(?n)lo pdfsets as build-time resources
## d4fb37cedfb7552a753bdc9c0c4792082f4b46e8: py-tensorflow: add libclang variant
## 4dc856a13e9066ca3249a593d351af8cda521fa3: root: add v6.40.00, v6.40.02
## 3dcad5bb860184c91c17b97a9f3b13252d26d309: readline: switch url for patch download
