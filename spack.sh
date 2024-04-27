## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
SPACK_VERSION="v0.21.0"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
ed8ecc469e7b87842a876323878831e301f136a2
53a45c820c983867e8b05cab3df34e98b468f932
4991a60eacb5df289383f755e40702b720ed0513
81e73b4dd4ea0bf6c6947359d3cee9d4270df13d
c485709f625429a88a184a099373d76c9438f8e3
6f08daf67020289e6a5ed1df9783ac5b2919e477
50051b56199992eb4395b8ff22913c1995311a8c
f01774f1d41781bc4b9e5abb5469e234168da663
16f4c53cd4cfb4bc6c9390f6e65217fc9ccc58c9
d171f314c77ba61b3cd780f159afe6abced5707d
b111064e221aae83e62226672cd8bf9a7524423d
3c54177c5d9032cb36cf154b553d739cbeb2d024
c07ddf83c32b7129247fe90eed486dd844047087
00875fbc749a7e4e979c35d59c0a8d60d32d4cd7
64cf67822471ec2d3df2625a6d713f80cbe7ff43
7a0c4e8017033430e5f15ed628be6b539e935ba9
48fcfda1e7c1781cab4cada6d099823b263ab0cc
8c29e90fa9962f4a44f39f47217b46c85176af28
1255620a14afa3ad4aad681a847a3a1704141976
963e2ca82883cdc1287f1035c15d1a7e9a6fe612
d3c796f2ce1da2dda198707def297aeab702d33c
9c47ecaeb25300ac2a6a2609628ecd4c928fcf49
19c20563cc86140aaf352d72079bd9de292be0ac
d50f8d7b19e07f25a3ce8de28ff9b352fd926d7f
9e4fab277b8a5b9ec5587c8a8b6514f12c8042a4
8f4f691e2b2a6263f661fb0a455bcaf73e90036a
ef4274ed2ee9545eab399a6249346b56b66415a4
42b739d6d5b69b825e7992cd88b0b076a9bf0a9e
c264cf12a21c44358739fbe1fa674d2cb497ab5d
2d71c6bb8e9816464f14f8878d1777e209784ad3
a0cd63c21067af59d6a976cc3e7b26c723e49373
c5e0270ef006b2b04d2f3f89bcaa6bf4d492faae
bcc5ded2051788d8d0800391d09379417c1caeb7
eb57d96ea94b0543a8d5ba943444e77e414cc82e
16d1ed35914262eea27cf41a2c99aea497adc17d
c352db764598cc4d04299913646bb55d7613eb8a
c31a998abb9f0b82a59bbfbf55b8111847aac8cb
c5b8d5c92a88707d0c949b2bd507b2dfc1b79506
d7e756a26b9450d7f4e94dac1747a729011e2140
6986e708775afbddbe6e8239fb2d8745931a0410
70fb0b35e55f8f9b3182b091bc8c40b8770041b7
86730c7b175369ac0490b096401a2912f087a6e9
b6d69bfad215a62b9d8078c6216ec50931f848eb
ba753ac380ef7f2a626a00fd15612913fb21ac4c
5140a9b6a3588d9e44a98a6a1f3993e7687ef2fe
98162aa2e1574b2e8a2a43976ad27eda92e5c65e
85c6d6dbab88f4cb40a20cf13204263c59c640e9
72f8611d3e6296691c128ced4f55776042813cc0
9ffe1799346fce7615eb03483545a08d7023b2ce
e8ae9a403ca7db7738d36bf41bf99977b9c88a84
5a52780f7cf09973c431f89713db1c571ddd2ccc
28d02dff6090b72e070c5b9497cd1f4372b4723f
6008ae0c607560e4320dad5dcb35aaa4e1bc5d50
62132919e1465a40e3522e40278e4bbc8ec32978
946c539dbd95cd78ababda66e58a1c3f8953c95a
---
## Optional hash table with comma-separated file list
read -r -d '' SPACK_CHERRYPICKS_FILES <<- \
--- || true
[70fb0b35e55f8f9b3182b091bc8c40b8770041b7]=var/spack/repos/builtin/packages/py-fsspec/package.py
[5140a9b6a3588d9e44a98a6a1f3993e7687ef2fe]=var/spack/repos/builtin/packages/py-jax/package.py,var/spack/repos/builtin/packages/py-jaxlib/package.py
[9c47ecaeb25300ac2a6a2609628ecd4c928fcf49]=lib/spack/spack/directives.py
[19c20563cc86140aaf352d72079bd9de292be0ac]=var/spack/repos/builtin/packages/abseil-cpp/package.py,var/spack/repos/builtin/packages/acts/package.py,var/spack/repos/builtin/packages/actsvg/package.py,var/spack/repos/builtin/packages/dd4hep/package.py,var/spack/repos/builtin/packages/hepmc3/package.py,var/spack/repos/builtin/packages/protobuf/package.py,var/spack/repos/builtin/packages/pythia8/package.py,var/spack/repos/builtin/packages/py-aiobotocore/package.py,var/spack/repos/builtin/packages/py-cdsapi/package.py,var/spack/repos/builtin/packages/py-cfgrib/package.py,var/spack/repos/builtin/packages/py-chex/package.py,var/spack/repos/builtin/packages/py-dm-haiku/package.py,var/spack/repos/builtin/packages/py-etils/package.py,var/spack/repos/builtin/packages/py-flit-core/package.py,var/spack/repos/builtin/packages/py-fsspec/package.py,var/spack/repos/builtin/packages/py-gcsfs/package.py,var/spack/repos/builtin/packages/py-h5netcdf/package.py,var/spack/repos/builtin/packages/py-importlib-metadata/package.py,var/spack/repos/builtin/packages/py-jax/package.py,var/spack/repos/builtin/packages/py-jaxlib/package.py,var/spack/repos/builtin/packages/py-netcdf4/package.py,var/spack/repos/builtin/packages/py-onnx/package.py,var/spack/repos/builtin/packages/py-onnxruntime/package.py,var/spack/repos/builtin/packages/py-pytest-asyncio/package.py,var/spack/repos/builtin/packages/py-pytest-timeout/package.py,var/spack/repos/builtin/packages/py-python-dotenv/package.py,var/spack/repos/builtin/packages/py-s3fs/package.py,var/spack/repos/builtin/packages/py-zarr/package.py,var/spack/repos/builtin/packages/xrootd/package.py
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## ed8ecc469e7b87842a876323878831e301f136a2: podio: Add the latest tag (0.17.2)
## 53a45c820c983867e8b05cab3df34e98b468f932: docker entrypoint.sh: fail multi-line RUN on first error with set -e
## 4991a60eacb5df289383f755e40702b720ed0513: podio: Add latest tag 0.17.3
## 81e73b4dd4ea0bf6c6947359d3cee9d4270df13d: root: new version 6.30.00
## c485709f625429a88a184a099373d76c9438f8e3: iwyu: new versions up 0.21 (depends_on llvm-17)
## 6f08daf67020289e6a5ed1df9783ac5b2919e477: root: add a webgui patch
## 50051b56199992eb4395b8ff22913c1995311a8c: geant4: new version 11.1.3
## f01774f1d41781bc4b9e5abb5469e234168da663: hepmc3: fix from_variant -> self.define
## 16f4c53cd4cfb4bc6c9390f6e65217fc9ccc58c9: py-bokeh: new version 3.3.1, and supporting packages
## d171f314c77ba61b3cd780f159afe6abced5707d: py-pygithub: new versions, dependencies
## b111064e221aae83e62226672cd8bf9a7524423d: py-htgettoken: use os.environ, avoid AttributeError
## 3c54177c5d9032cb36cf154b553d739cbeb2d024: edm4hep: add latest tag for 0.10.2
## c07ddf83c32b7129247fe90eed486dd844047087: py-torch: set env OpenBLAS_HOME
## 00875fbc749a7e4e979c35d59c0a8d60d32d4cd7: py-torch: patch for ${OpenBLAS_HOME}/include/openblas
## 64cf67822471ec2d3df2625a6d713f80cbe7ff43: py-torch: move patch before def patch
## 7a0c4e8017033430e5f15ed628be6b539e935ba9: acts: new versions 31.*
## 48fcfda1e7c1781cab4cada6d099823b263ab0cc: setup-env.sh: if exe contains qemu, use /proc/$$/comm instead
## 8c29e90fa9962f4a44f39f47217b46c85176af28: Build cache: make signed/unsigned a mirror property
## 1255620a14afa3ad4aad681a847a3a1704141976: Fix infinite recursion when computing concretization errors
## 963e2ca82883cdc1287f1035c15d1a7e9a6fe612: edm4hep: add latest tag 0.10.3
## d3c796f2ce1da2dda198707def297aeab702d33c: pythia8: new version 8.310
## 9c47ecaeb25300ac2a6a2609628ecd4c928fcf49: directives: add checked_by field to license(), add some license checks
## 19c20563cc86140aaf352d72079bd9de292be0ac: Initial License Checkin
## d50f8d7b19e07f25a3ce8de28ff9b352fd926d7f: root: sha256 change on latest versions
## 9e4fab277b8a5b9ec5587c8a8b6514f12c8042a4: [root] New variants, patches
## 8f4f691e2b2a6263f661fb0a455bcaf73e90036a: hepmc3: add v3.2.7
## ef4274ed2ee9545eab399a6249346b56b66415a4: podio: Add latest tag 0.17.4
## 42b739d6d5b69b825e7992cd88b0b076a9bf0a9e: podio: depends_on py-graphviz type run (for podio-vis)
## c264cf12a21c44358739fbe1fa674d2cb497ab5d: dd4hep: avoid IndexError in setup_run_environment
## 2d71c6bb8e9816464f14f8878d1777e209784ad3: dd4hep: add v1.27.1
## a0cd63c21067af59d6a976cc3e7b26c723e49373: dd4hep: new version 1.27.2
## c5e0270ef006b2b04d2f3f89bcaa6bf4d492faae: dd4hep: remove self-referential dependencies
## bcc5ded2051788d8d0800391d09379417c1caeb7: dd4hep: new version 1.28
## eb57d96ea94b0543a8d5ba943444e77e414cc82e: geant4/geant4-data: add v10.0.4
## 16d1ed35914262eea27cf41a2c99aea497adc17d: geant4: new version 11.2.0
## c352db764598cc4d04299913646bb55d7613eb8a: vecgeom: Use correct checksum for version 1.2.5
## c31a998abb9f0b82a59bbfbf55b8111847aac8cb: VecGeom: new version 1.2.7 and fix URLs
## c5b8d5c92a88707d0c949b2bd507b2dfc1b79506: geant4: new version v11.2.1
## d7e756a26b9450d7f4e94dac1747a729011e2140: onnxruntime: fix the call to as_string() operator
## 6986e708775afbddbe6e8239fb2d8745931a0410: [abseil-cpp] New version 20230802.1
## 70fb0b35e55f8f9b3182b091bc8c40b8770041b7: py-transformers: add v4.35.2
## 86730c7b175369ac0490b096401a2912f087a6e9: py-fsspec: fix import tests
## b6d69bfad215a62b9d8078c6216ec50931f848eb: py-flit-core: fix import tests
## ba753ac380ef7f2a626a00fd15612913fb21ac4c: Make things easier to concretize
## 5140a9b6a3588d9e44a98a6a1f3993e7687ef2fe: py-keras: add v3.0.5
## 98162aa2e1574b2e8a2a43976ad27eda92e5c65e: py-earth2mip: add new package
## 85c6d6dbab88f4cb40a20cf13204263c59c640e9: (py-)onnx: new version 1.14.{0,1}, 1.15.0
## 72f8611d3e6296691c128ced4f55776042813cc0: acts: new version 32.0.0
## 9ffe1799346fce7615eb03483545a08d7023b2ce: acts: fix self-referential dependencies
## e8ae9a403ca7db7738d36bf41bf99977b9c88a84: acts: depends_on py-onnxruntime when +onnx for @23.3:
## 5a52780f7cf09973c431f89713db1c571ddd2ccc: acts: new version 33.1.0
## 28d02dff6090b72e070c5b9497cd1f4372b4723f: pythia8: new version 8.311
## 6008ae0c607560e4320dad5dcb35aaa4e1bc5d50: geant4-data: fix versions for 11.2
## 62132919e1465a40e3522e40278e4bbc8ec32978: xrootd: new version 5.6.9
## 946c539dbd95cd78ababda66e58a1c3f8953c95a: osg-ca-certs: new version osg-1.119 igtf-1.128
