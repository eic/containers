## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
SPACK_VERSION="v0.20.1"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS <<- \
--- || true
ef5d110d4abd2411d6bde82d738b205eb6672fe8
9ee2d79de172de14477a78e5d407548a63eea33a
776ab132760d63eab0703b7c0ebebc72a8443f5b
188168c476eabe99764634db8d78eb3f9ea2a927
b3268c2703b84f4e4961c1e2cdf43e8998f283e6
4ae1a73d54b33bc4876535422d3f3bf3d9641c51
9e4c4be3f523a0d144870dbf5645ad7bf0ff04be
d8a9b42da6cdef3a08ec48931bf282e5e4811d38
ce0b9ea8cf184c9048cac1ae88f2d69f0e4520c7
ea1439dfa11a3996c9927ed792dc9fe4b7efc1b8
5996aaa4e3b8b37f847da356489bb27958b968f1
31431f967a59c07585021cba40683c2ca6ff2c47
316bfd8b7d0d1bc63a7bccf030845775a442a317
6e47f1645f31ce598d7f1f9770e24b483fb117d9
63bb2c9bad8acb018f220630e5ce58e4a039d8a2
ed76eab6943221f17776fd8d128ade6ba69e492c
6c5d125cb06a86ce05bec27ae9fb9b07103bc1c5
e3e7609af4903be7df42b6ae5ccf9a20293503d2
df4a2457a41e7ab634e86d3148d8b22a9f433a6a
5ba4a2b83a0fabbfd221328a3c96955e9395b6ca
eea743de461feca88fabf8c87e8fe617a368250c
29835ac3437a7f975f7fdd22fac864b3273ff7d5
581f45b63908dda8429b63c32047fd5295a95507
cf031e83f0149cd2c43d04f877dc26cc9d9e7894
dd747c5c4892fd0c8f6831786c2140198394cc4b
aa9eb331080a3edeb876dd80552bb59243c69783
f0658243c06119f6d0bf9bf72b162bb7be129344
b25f8643ff6f28d9ca0c23d4eb46aadb840683cf
c9e1e7d90c9880b158e29bf6e721065416d21b90
537ab481670bad654225f488fb4ec92d25f148a8
2a797f90b431d33f609dc1d92b2908f5734f4d50
a9e78dc7d897c146b11a93fd8c0176d0e886f2b4
6b51bfb713b7f9d6203b69ef79a198758c99de94
b99288dcae9fd240a6d483d8b13940e52bfd8575
3e2d1bd4133b437b10584a5e725d6fee8b5ca294
f709518916ffe11588cffa3a5821c1e49e94b8d2
6cd2241e49a393d7ac32b46064a2d2f4e53f7d86
6f248836eafbee3b2c0612d250e201d3b3a57472
5400b49ed6dc7001b1645b5d31bbcc7d830c15c2
73ad3f729e8a5206d717d9d66468a19bb11d2940
bd58801415dc0acebfd7368f66c43e50563a9891
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## ef5d110d4abd2411d6bde82d738b205eb6672fe8: Fix multiple quadratic complexity issues in environments
## 9ee2d79de172de14477a78e5d407548a63eea33a: libxpm package: fix RHEL8 build with libintl
## 776ab132760d63eab0703b7c0ebebc72a8443f5b: [xrootd] New variants, new version, improve build config
## 188168c476eabe99764634db8d78eb3f9ea2a927: podio: Add 0.16.5 tag
## b3268c2703b84f4e4961c1e2cdf43e8998f283e6: freetype: add pic and shared variants
## 4ae1a73d54b33bc4876535422d3f3bf3d9641c51: (r-rcpp)ensmallen: new package
## 9e4c4be3f523a0d144870dbf5645ad7bf0ff04be: mlpack: new package
## d8a9b42da6cdef3a08ec48931bf282e5e4811d38: actsvg: add v0.4.33
## ce0b9ea8cf184c9048cac1ae88f2d69f0e4520c7: acts: ensure Python_EXECUTABLE uses ^python when +python
## ea1439dfa11a3996c9927ed792dc9fe4b7efc1b8: acts: new variant cxxstd
## 5996aaa4e3b8b37f847da356489bb27958b968f1: acts: new versions 23.[3-5].0, 24.0.0, 25.0.[0-1], 26.0.0, 27.[0-1].0, 28.0.0
## 31431f967a59c07585021cba40683c2ca6ff2c47: Environment/depfile: fix bug with Git hash versions
## 316bfd8b7d0d1bc63a7bccf030845775a442a317: opencascade: new variants
## 6e47f1645f31ce598d7f1f9770e24b483fb117d9: opencascade: typo in True
## 63bb2c9bad8acb018f220630e5ce58e4a039d8a2: py-cryptography: does not run-depend on py-setuptools-rust
## ed76eab6943221f17776fd8d128ade6ba69e492c: geant4: new version 11.1.2
## 6c5d125cb06a86ce05bec27ae9fb9b07103bc1c5: cernlib: new variant shared
## e3e7609af4903be7df42b6ae5ccf9a20293503d2: edm4hep: Add version 0.9
## df4a2457a41e7ab634e86d3148d8b22a9f433a6a: Fix broken semver regex
## 5ba4a2b83a0fabbfd221328a3c96955e9395b6ca: podio: bump minimal version of catch2
## eea743de461feca88fabf8c87e8fe617a368250c: podio: Add py-tabulate as new run and test dependency
## 29835ac3437a7f975f7fdd22fac864b3273ff7d5: podio: add 0.16.6 tag and mark older releases as deprecated
## 581f45b63908dda8429b63c32047fd5295a95507: podio: Add latest tags and variants and update dependencies accordingly
## cf031e83f0149cd2c43d04f877dc26cc9d9e7894: compilers/gcc.py: support cxx{20,23}_flag
## dd747c5c4892fd0c8f6831786c2140198394cc4b: xerces-c: support variant cxxstd=20
## aa9eb331080a3edeb876dd80552bb59243c69783: boost: support variant cxxstd=20
## f0658243c06119f6d0bf9bf72b162bb7be129344: clhep: support variant cxxstd=20
## b25f8643ff6f28d9ca0c23d4eb46aadb840683cf: geant4, vecgeom: support variant cxxstd=20
## c9e1e7d90c9880b158e29bf6e721065416d21b90: acts: impose cxxstd variant on geant4 dependency
## 537ab481670bad654225f488fb4ec92d25f148a8: acts: use f-strings
## 2a797f90b431d33f609dc1d92b2908f5734f4d50: acts: add v28.1.0:30.3.2
## a9e78dc7d897c146b11a93fd8c0176d0e886f2b4: acts: new variant +binaries when +examples
## 6b51bfb713b7f9d6203b69ef79a198758c99de94: edm4hep: Add tag for version 0.10 and deprecate older versions
## b99288dcae9fd240a6d483d8b13940e52bfd8575: edm4hep: add edm4hep to PYTHONPATH
## 3e2d1bd4133b437b10584a5e725d6fee8b5ca294: lcio: Add latest version 2.20
## f709518916ffe11588cffa3a5821c1e49e94b8d2: podio, edm4hep and lcio: add lib and lib64 to LD_LIBRARY_PATH
## 6cd2241e49a393d7ac32b46064a2d2f4e53f7d86: edm4hep: Add 0.10.1 tag and update maintainers
## 6f248836eafbee3b2c0612d250e201d3b3a57472: dd4hep: restrict podio versions
## 5400b49ed6dc7001b1645b5d31bbcc7d830c15c2: dd4hep: add LD_LIBRARY_PATH for plugins for Gaudi
## 73ad3f729e8a5206d717d9d66468a19bb11d2940: dd4hep: add patch to fix missing hits when using LCIO
## bd58801415dc0acebfd7368f66c43e50563a9891: dd4hep: fix setting LD_LIBRARY_PATH
## // Following disabled due to https://github.com/spack/spack/pull/37372
## // c7cca3aa8d11789eaee9bfc80b8417ffea511532: dd4hep: new version 1.26
## // e1373d5408170047626583916db02911585c133a: dd4hep: make sure to find libraries correctly
## // a095c8113d5065bcb3d529269bc1de268df6791f: dd4hep: Add tag for version 1.27
