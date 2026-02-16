## Spack organization and repository, e.g. spack/spack-packages
SPACKPACKAGES_ORGREPO="spack/spack-packages"

## Spack github version, e.g. v2025.07.0 or commit hash
## Note: nightly builds will use e.g. develop
## Note: when changing this, also make new buildcache public
## (default is only visible with internal authentication)
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
c75e10845431600b163c597545bd099e427c62f5
438a7d95de1b81e15107edbf341b20824ec80635
6b57d7a93de84dd5492b9308a9612924ab641dce
ba94c07db577eaf5eb4b0450721fbc7e98879922
f201ecd5e5923b394d14f74bc220dea06b9ab28f
2e05bbbe808442e761647da571500ee128654f4f
9ec50db07733195bba922b8c6dcbbb1de9c56adf
d95db21e9c9fa6eab1a9e62e2ba56066f2f955a7
be6546b82b43d82edba804f1e362a709809ba537
f5742718da7bd1d078ddc8423011a82ef2e3c759
922b2f6011dbf01aebb332a1ebf949b105c74247
2ba80e697faf80613b038615b2345b7a777cc438
9e8f996350ac51c620e61a3a3980577fe471e35a
a4cc9fad86c9c3353e65bd379f708f70d9984bf0
760f3889877f17df24229a03d5dda25189b88a29
2de6b7a78840d8e67113f190783a1c936709b643
7743e5ac5cdf9075800b3edacfed628c795a9a5e
b9ad19ee2ce47f8b7fbe187d41d898f873bbc121
931b8f47ff9470b3f957f0bb462964702277301a
5f36a2b536a22ea3692bfdcd48a6c0c71e6488cf
58593e5d028737fef024c8136045b9d3f988e3e3
ab1175cb7eb83b4b0764233bc4dcdf8c3b902345
10c88baef26836bcaad5eacaf473eea7defeba09
6677374f581c270f691ace68d30511d365cc0f9d
58da510aaeb37d49e2ce658679e95fd79b03d684
e87325e40627e4113c5e374f83e086f2421e005a
a1437186c1d979ce112d52be178d0fb88b70f332
cfa8d650480c409de2d568cf1355bf7e509f4c1c
580bdd5b82e9329a4b5c0b30411e43ea3221d958
688d5e5e20fa9aa2647026143205c8aaa0625590
7e4068a0ae5340de6119277e04ebf68f544b4453
208b3c478e74e5217724b4894d1db941b0c13555
9ba7aca4be1e05e17c911aa48f6eb7ca5d3c8df7
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
## 22dadd619053ff0872903549db616200bda082f0: claude-code: new package
## 559789f67245a40306aeea636b61348e97d4f092: estarlight: add thru v1.2.0
## 95c45b6c3322e151fd29ed00ea10567b97705ee4: py-tensorflow: modify cuDNN dependency versions when +cuda
## d6f99b8d611cf740eb45e13df2c84044a4ca6ae4: py-tensorflow: patch to build with +cuda
## 5c37f836753e8f9683fdc547f3661c5045abcbd1: root: require openblas ~ilp64 symbol_suffix=none when ^openblas
## c75e10845431600b163c597545bd099e427c62f5: dd4hep: v1.33
## 438a7d95de1b81e15107edbf341b20824ec80635: root: add v6.36.06
## 6b57d7a93de84dd5492b9308a9612924ab641dce: podio: ensure Python.h is found in ROOT ACLiC
## ba94c07db577eaf5eb4b0450721fbc7e98879922: podio: use headers.directories[0] to get str, not list
## f201ecd5e5923b394d14f74bc220dea06b9ab28f: acts: add v44.2.0
## 2e05bbbe808442e761647da571500ee128654f4f: acts: add v44.3.0
## 9ec50db07733195bba922b8c6dcbbb1de9c56adf: ollama: add through v0.13.1
## d95db21e9c9fa6eab1a9e62e2ba56066f2f955a7: root: add v6.38.00
## be6546b82b43d82edba804f1e362a709809ba537: gaudi: allow newer fmt for v39
## f5742718da7bd1d078ddc8423011a82ef2e3c759: gaudi: workaround test-dependency bug with a when
## 922b2f6011dbf01aebb332a1ebf949b105c74247: celeritas: add v0.6.3
## 2ba80e697faf80613b038615b2345b7a777cc438: py-flatbuffers: add v25.9.23
## 9e8f996350ac51c620e61a3a3980577fe471e35a: py-dask: add v2025.3.0 (for py-dask-awkward)
## a4cc9fad86c9c3353e65bd379f708f70d9984bf0: py-distributed: fix typo
## 760f3889877f17df24229a03d5dda25189b88a29: py-dask, py-distributed: add v2024.12.1 (for py-hist)
## 2de6b7a78840d8e67113f190783a1c936709b643: py-dask, py-distributed: fix style
## 7743e5ac5cdf9075800b3edacfed628c795a9a5e: harfbuzz: Ensure consistent meson builder with cairo dependency
## b9ad19ee2ce47f8b7fbe187d41d898f873bbc121: harfbuzz/pango: add harfbuzz gobject variant (& req for pango)
## 931b8f47ff9470b3f957f0bb462964702277301a: openblas: patch for +dynamic_dispatch target=aarch64
## 5f36a2b536a22ea3692bfdcd48a6c0c71e6488cf: py-onnxruntime: add v1.21.1, v1.22.2
## 58593e5d028737fef024c8136045b9d3f988e3e3: py-onnxruntime: patch to add linker flag -z noexecstack
## ab1175cb7eb83b4b0764233bc4dcdf8c3b902345: python: disable tkinter in config_args for Python 3.12+ if ~tkinter in spec
## 10c88baef26836bcaad5eacaf473eea7defeba09: python: add v3.14.2, v3.13.11
## 6677374f581c270f691ace68d30511d365cc0f9d: Added GIL removal as option for python
## 58da510aaeb37d49e2ce658679e95fd79b03d684: Python: more changes for free-threaded support
## e87325e40627e4113c5e374f83e086f2421e005a: acts: add v44.4.0
## a1437186c1d979ce112d52be178d0fb88b70f332: acts: narrow when range on podio when +edm4hep +examples
## cfa8d650480c409de2d568cf1355bf7e509f4c1c: dd4hep: Add version 1.34
## 580bdd5b82e9329a4b5c0b30411e43ea3221d958: pythia8: add v8.316
## 688d5e5e20fa9aa2647026143205c8aaa0625590: dd4hep: add v1.35
## 7e4068a0ae5340de6119277e04ebf68f544b4453: podio, edm4hep, dd4hep: conflicts ^python +freethreading
## 208b3c478e74e5217724b4894d1db941b0c13555: podio: Add version 1.7
## 9ba7aca4be1e05e17c911aa48f6eb7ca5d3c8df7: edm4hep: Add version 1.0 and update podio dependency
