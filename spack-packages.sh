## Spack organization and repository, e.g. spack/spack-packages
SPACKPACKAGES_ORGREPO="spack/spack-packages"

## Spack github version, e.g. v2025.07.0 or commit hash
## note: nightly builds will use e.g. develop
SPACKPACKAGES_VERSION="v2025.07.0"

## Space-separated list of spack-packages cherry-picks
read -r -d '' SPACKPACKAGES_CHERRYPICKS <<- \
--- || true
b5ffbcc4aa43bffbffa96ff9a436a68773e10933
b6b6d79c25c1496472f9535ec33c9030b27353ab
405e97751385dccbd6ec6e6f3b57dc28fc04c76b
ba00d764b91db70bce8236bc528a1d4af37c4ce9
4b243eb07a483a6bf527c2f74e5766b35afa528b
948d4ea14409e38d47882b5a5c2d61d99d02b30b
---
## Optional hash table with comma-separated file list
read -r -d '' SPACKPACKAGES_CHERRYPICKS_FILES <<- \
--- || true
---
## Ref: https://github.com/spack/spack-packages/commit/[hash]
## [hash]: [description]
## b5ffbcc4aa43bffbffa96ff9a436a68773e10933: strace: add v6.15
## b6b6d79c25c1496472f9535ec33c9030b27353ab: iwyu: add patch for 0.23
## 405e97751385dccbd6ec6e6f3b57dc28fc04c76b: iwyu,g2,r-curl: requires(pkg) -> requires(^pkg)
## ba00d764b91db70bce8236bc528a1d4af37c4ce9: py-gfal2-python: depends_on c
## 4b243eb07a483a6bf527c2f74e5766b35afa528b: gobject-introspection: restore setuptools@44: support
## 948d4ea14409e38d47882b5a5c2d61d99d02b30b: scikit-hep packages: update to latest major.minor versions
