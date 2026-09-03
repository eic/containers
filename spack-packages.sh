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
dcf9162c02da6fbde05bdbc595561b7956f5381b
92bf08b6223c29ab81983daf0408a5a991934fa6
7cd1d840b9fe0c17ef24cbb2d83bff443fd15279
acac89d6bb7079412e711a50a3f06681132a2723
438abd1e09f0cea9cb0ccc7e0326adcd0408196b
d4fb37cedfb7552a753bdc9c0c4792082f4b46e8
4dc856a13e9066ca3249a593d351af8cda521fa3
5c1471ca2093e1ed98abab9ea482f1c45845fb1b
c61e6769fe7556654815193f8ff2efb6cfec5fda
bb6307167d40820ccd3fbf62bb59c22fd05c6a47
b7819dfb21e2716761e0a99bc93a851eef0e6343
6fff3bd98c2157600cb716a3d7116f0a235446f1
0e793b360b1383044923a19146f7d977f3107a41
4c53d69e7e02fb346500b6269e43a26d1010d0f7
ded706e8eb08bae4ac1cd4618c594bee4040a00e
8090c2e88e44621599b1e6e2a1f6243fd8ec78d3
c44cd71db91d6e6c68cb604dcb87311b49b1bedb
33d01efa54ffc5b211cd5abc2df74841c032a722
7e581611d81312d2a4228ad5d0b67bdd93217915
683c5a698d88d657a99f3adefee0fe98d30927ae
409826414a2221be56011f8f0f912905dae558cd
63b8b9c3ac8ddcb2b9aafcd8160ff33bd6210f51
4b54f295bed925f1a33f3954bd05903e53142406
5945d81a8359eed559ec60b1be9151de57473f51
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
## dcf9162c02da6fbde05bdbc595561b7956f5381b: cargo-c: depends_on pkgconfig
## 92bf08b6223c29ab81983daf0408a5a991934fa6: professor: cast version to str
## 7cd1d840b9fe0c17ef24cbb2d83bff443fd15279: professor: add v2.5.6 and re-enable in the HEP stack
## acac89d6bb7079412e711a50a3f06681132a2723: cuda: append --allow-unsupported-compiler to CUDAFLAGS for dependent_spec
## 438abd1e09f0cea9cb0ccc7e0326adcd0408196b: herwig3: add CT14(?n)lo pdfsets as build-time resources
## d4fb37cedfb7552a753bdc9c0c4792082f4b46e8: py-tensorflow: add libclang variant
## 4dc856a13e9066ca3249a593d351af8cda521fa3: root: add v6.40.00, v6.40.02
## 5c1471ca2093e1ed98abab9ea482f1c45845fb1b: edm4hep: Add version 1.1
## c61e6769fe7556654815193f8ff2efb6cfec5fda: hepmc3: patch to remove cdll.LoadLibrary of unversioned libCore.so
## bb6307167d40820ccd3fbf62bb59c22fd05c6a47: acts: prepend to PYTHONPATH
## b7819dfb21e2716761e0a99bc93a851eef0e6343: acts: add v46.4.0 through v46.8.1
## 6fff3bd98c2157600cb716a3d7116f0a235446f1: acts: cleanup deps for removed versions
## 0e793b360b1383044923a19146f7d977f3107a41: pandora*: Update PandoraPFA repository URLs
## 4c53d69e7e02fb346500b6269e43a26d1010d0f7: pandora*: add v5.*
## ded706e8eb08bae4ac1cd4618c594bee4040a00e: acts: pass root variant to examples
## 8090c2e88e44621599b1e6e2a1f6243fd8ec78d3: root: add v6.40.04
## c44cd71db91d6e6c68cb604dcb87311b49b1bedb: podio: add a patch to be able to build with fmt 12
## 33d01efa54ffc5b211cd5abc2df74841c032a722: podio: add arrow variant
## 7e581611d81312d2a4228ad5d0b67bdd93217915: podio,sio: url_for_version for main version
## 683c5a698d88d657a99f3adefee0fe98d30927ae: dd4hep: url_for_version for master version
## 409826414a2221be56011f8f0f912905dae558cd: podio: Add version 1.8 and new parquet variant
## 63b8b9c3ac8ddcb2b9aafcd8160ff33bd6210f51: edm4hep: patch for new podio arrow targets
## 4b54f295bed925f1a33f3954bd05903e53142406: compiler-wrapper: add 1.1.0-build-id prototype version (spack-packages#6214)
## 5945d81a8359eed559ec60b1be9151de57473f51: elfutils: patch debuginfod_find_source to accept ./-relative filenames (spack-packages #6259)
