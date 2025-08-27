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
215e9f93f4de43095bd12e39809b9afeb89655f0
8aaec9b76104af2cf58e7be55485d6c2385b41ab
8751ca4c4ba54559b40cdaa3c319bf14db72e28e
2c1e68ded81add6d3d0fbc005ad19b0727639204
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
## 215e9f93f4de43095bd12e39809b9afeb89655f0: py-boost-histogram: depends_on py-setuptools-scm type build
## 8aaec9b76104af2cf58e7be55485d6c2385b41ab: py-uproot: depends_on py-numpy@:1 when @:5.3.2
## 8751ca4c4ba54559b40cdaa3c319bf14db72e28e: py-hist: add v2.6.2 thru v2.8.0 (switch to hatchling)
## 2c1e68ded81add6d3d0fbc005ad19b0727639204: pythia8: add v8.314 and v8.315
