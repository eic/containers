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