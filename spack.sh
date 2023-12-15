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
cfa2f19f48699a762af77ece8a9c5bc4db3a75d5
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
## cfa2f19f48699a762af77ece8a9c5bc4db3a75d5: py-htgettoken: use os.environ, avoid AttributeError
