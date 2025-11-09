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
a118c877bcca1d71810528ba481b8d3f819035f1
0c164b846058d9c57c9adb6b17ef86ead9f4b8c4
b440c61b9cddfab0fd59dd5fc607c95247a18bc9
698ce0531e4be2d55ca667d6f9341636397c2662
387d9a5213cc6e3fd738b995b25d6facde4cc902
1d53be2a26ecb7809c1f6006ed8cbfe7febee7a9
a115a811bdfce4db5298a9ba9b7903ccfb0de101
22dadd619053ff0872903549db616200bda082f0
7fad8a78d35b5556e1d7aa92a71a4e1c58a1665a
1b976bbdf7c5bce37d6541beb93445791f9292c6
20aa538bd0d33743b8cd9dd9179c759b85615d47
795ad32793a7dfda1086f31b7e49cf4ae52672f6
e61079273e806301d76cc64f53fb034980988583
b063312bb52fb62010e04588f6b16d37e16c8d02
b7870dfad11c4e8ca9690b0895c98f16d79f5398
1e8f896b2807bcc48553e90d6212f0931fa5262f
e998e20d3979c5aa47faaf59a8020e3fab13ab97
---
## Optional hash table with comma-separated file list
read -r -d '' SPACKPACKAGES_CHERRYPICKS_FILES <<- \
--- || true
[b063312bb52fb62010e04588f6b16d37e16c8d02]=repos/spack_repo/builtin/packages/py_tensorflow/package.py
[7fad8a78d35b5556e1d7aa92a71a4e1c58a1665a]=repos/spack_repo/builtin/packages/py_tensorflow/package.py,repos/spack_repo/builtin/packages/py_tensorboard/package.py
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
## a118c877bcca1d71810528ba481b8d3f819035f1: py-hist: fix py-boost-histogram dependency
## 0c164b846058d9c57c9adb6b17ef86ead9f4b8c4: g4vg: new version 1.0.5
## b440c61b9cddfab0fd59dd5fc607c95247a18bc9: force CMAKE_INSTALL_RPATH to prefix/lib/root for ROOT
## 698ce0531e4be2d55ca667d6f9341636397c2662: root: add v6.36.02
## 387d9a5213cc6e3fd738b995b25d6facde4cc902: acts: only init submodules when +odd
## 1d53be2a26ecb7809c1f6006ed8cbfe7febee7a9: root: add v6.36.04
## a115a811bdfce4db5298a9ba9b7903ccfb0de101: github-copilot: new package
## 22dadd619053ff0872903549db616200bda082f0: claude-code: new package
## 1b976bbdf7c5bce37d6541beb93445791f9292c6: py-keras: add v3.11.0
## 20aa538bd0d33743b8cd9dd9179c759b85615d47: py-keras: add v3.11.1
## 795ad32793a7dfda1086f31b7e49cf4ae52672f6: py-keras: add v3.11.2
## e61079273e806301d76cc64f53fb034980988583: py-keras: add v3.11.3
## b7870dfad11c4e8ca9690b0895c98f16d79f5398: py-keras: add v3.12.0
## b063312bb52fb62010e04588f6b16d37e16c8d02: Remove Python-related deprecations
## 7fad8a78d35b5556e1d7aa92a71a4e1c58a1665a: py-tensorflow: add v2.19, v2.20
## 1e8f896b2807bcc48553e90d6212f0931fa5262f: simsipm: Add conflict for aarch64
## e998e20d3979c5aa47faaf59a8020e3fab13ab97: py-immutables: add v0.21
