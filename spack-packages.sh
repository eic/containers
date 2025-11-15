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
c71f8e48245012565ac7b0648dfda137b0071de7
4ef82e75f5cae7b4d093e41043e26b259498264e
8d027b1651840631350d0ba9f30624f2baf26350
566e1b070e17ffe8c2d0bf4122568af8a81db1cd
048bffaea064919ccfc2f740e14bbb987e7f5c7e
6b57d7a93de84dd5492b9308a9612924ab641dce
ba94c07db577eaf5eb4b0450721fbc7e98879922
57a0c5d83aba319c37e51c7a6f965f28f49cdb77
d0b0e511376f74be2cd3a2878bed781d39a6066a
a6762cd1b4dff3297dd83664a6c09450324fc7bd
158693457ba1717a89a9e2f9614c6982b6aff441
a46e40be55d002e4708303735f7eb4aca2482d0a
96d1e30c389599be9b3d95a0af16b49afd8b6e31
2050ba18c273506ebfd90744315850e55766fff7
3c85253b0bd2bb61eae6b5532d657a34e0939c69
d6b78b9ed0cf6ac3d6ddfcbc287bc0db3cd645e7
f201ecd5e5923b394d14f74bc220dea06b9ab28f
2e05bbbe808442e761647da571500ee128654f4f
9ec50db07733195bba922b8c6dcbbb1de9c56adf
d95db21e9c9fa6eab1a9e62e2ba56066f2f955a7
9cf8ee9c28465568d0b8871f245c400470e74ec7
78a6c5f0a2531a78be5c9dd9235cf92036d541f5
be6546b82b43d82edba804f1e362a709809ba537
f5742718da7bd1d078ddc8423011a82ef2e3c759
56e5282f7ef78180895b5d99db57d2a166b6d0e1
922b2f6011dbf01aebb332a1ebf949b105c74247
2ba80e697faf80613b038615b2345b7a777cc438
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
## bc25e5eb2f8f7a8733cdc10d92e9787358c82cfa: actsvg: patch version numbers into source source
## c4d983b764d7b1ee2b63da79f5f25365ac61ce7a: Julia: add v1.11.6
## 44da889cc86bb8a5315c729a7c79f2c002c9c951: Julia: add v1.11.7
## 5c37f836753e8f9683fdc547f3661c5045abcbd1: root: require openblas ~ilp64 symbol_suffix=none when ^openblas
## c75e10845431600b163c597545bd099e427c62f5: dd4hep: v1.33
## 438a7d95de1b81e15107edbf341b20824ec80635: root: add v6.36.06
## c71f8e48245012565ac7b0648dfda137b0071de7: podio: Add latest tag 1.4 and 1.4.1
## 4ef82e75f5cae7b4d093e41043e26b259498264e: Deprecation removals: P
## 8d027b1651840631350d0ba9f30624f2baf26350: podio: Add version 1.5
## 566e1b070e17ffe8c2d0bf4122568af8a81db1cd: podio: add v1.6
## 048bffaea064919ccfc2f740e14bbb987e7f5c7e: podio: Add the conditional value 23 for cxxstd
## 6b57d7a93de84dd5492b9308a9612924ab641dce: podio: ensure Python.h is found in ROOT ACLiC
## ba94c07db577eaf5eb4b0450721fbc7e98879922: podio: use headers.directories[0] to get str, not list
## 57a0c5d83aba319c37e51c7a6f965f28f49cdb77: eigen: add v3.4.0-44-g37248b26a
## d0b0e511376f74be2cd3a2878bed781d39a6066a: eigen: Use Release build type by default
## a6762cd1b4dff3297dd83664a6c09450324fc7bd: acts: only init submodules when +odd; HEP: rm opendatadetector
## 158693457ba1717a89a9e2f9614c6982b6aff441: Deprecation removals: A-D
## a46e40be55d002e4708303735f7eb4aca2482d0a: acts: deprecate versions :38
## 96d1e30c389599be9b3d95a0af16b49afd8b6e31: eigen: add versions 5.0.0 and 3.4.1
## 2050ba18c273506ebfd90744315850e55766fff7: acts: add upper limit on podio
## 3c85253b0bd2bb61eae6b5532d657a34e0939c69: acts: add v44.0.0, v44.0.1, v44.1.0
## d6b78b9ed0cf6ac3d6ddfcbc287bc0db3cd645e7: acts: Add +gnn variant and add necessary dependencies
## f201ecd5e5923b394d14f74bc220dea06b9ab28f: acts: add v44.2.0
## 2e05bbbe808442e761647da571500ee128654f4f: acts: add v44.3.0
## 9ec50db07733195bba922b8c6dcbbb1de9c56adf: ollama: add through v0.13.1
## d95db21e9c9fa6eab1a9e62e2ba56066f2f955a7: root: add v6.38.00
## 9cf8ee9c28465568d0b8871f245c400470e74ec7: Deprecation removals: E-H
## 78a6c5f0a2531a78be5c9dd9235cf92036d541f5: edm4hep: Add latest tags and update dependencies
## be6546b82b43d82edba804f1e362a709809ba537: gaudi: allow newer fmt for v39
## f5742718da7bd1d078ddc8423011a82ef2e3c759: gaudi: workaround test-dependency bug with a when
## 56e5282f7ef78180895b5d99db57d2a166b6d0e1: celeritas: new versions 0.6.1, 0.6.2
## 922b2f6011dbf01aebb332a1ebf949b105c74247: celeritas: add v0.6.3
## 2ba80e697faf80613b038615b2345b7a777cc438: py-flatbuffers: add v25.9.23
