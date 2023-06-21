## Spack organization and repository, e.g. spack/spack
SPACK_ORGREPO="spack/spack"

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
SPACK_VERSION="v0.19.2"

## Space-separated list of spack cherry-picks
read -r -d '' SPACK_CHERRYPICKS || true <<- \
---
b5ef5c2eb5145020f9de1bcb964626ce6ac2d02e
99056e03bd3e903b222e300636ec484d85d4b3fb
f3f8b31be54280c6ef0b5f95ab85604aba3dff30
0ea81affd18820933640279bbc687038b3296a4e
dceb4c9d655d0529e112b8929558be60973b39f7
f2b0c1deab87da3b5aa4c1f2ef4d6af06fa4e32d
2f057d729da61e8c12828df44377f0a93fed820f
39a1f1462b0abf12dfaccd33f84142c852c4b56e
4b12d015e1c316b4837e02ae37e2c69a8a647180
f83d47442dade012b1019840181b8dd459fd8edd
7f1467e795b1cab8b4855e019910c509896ea0e1
ebc24b7063ba9a8eb43b4424aac5143cf958d76f
a47ebe57841f13239e881ed69eab4949b1d98c32
ab999d5af90f1bff644b5134bb370b2716e1bcf0
62da76cb5dca4d52c43bee06230cca6a5882f05d
cc2ae9f270befa554ba8b09c68e89bb8248ea650
ae98d2ba2fcefa9d027e2d6ccc6e7558a32e7228
ae189cfab8d9036e8d39bbd3f1b61b400d1fcd5b
3afe6f1adcc24335cbca9a9c03ffea188f802766
559c3de213707b5d52d899fd0382495f2cc8508d
8e84dcd7ef999e2659822b34372515175f1723c4
65bd9b9ac556480b4a9dcc60f7539492af195d4a
1a32cea11495cbdd699fea4fe622babab83e630d
6edc4807369a05786e36f63b5d959588ae94a1fa
af74680405c931dab16c6674f9b97a32bf3f1122
0a952f8b7bf6f70009dd5821bccbaf9170c73d07
f050b1cf7835fd31992b020e1061c52294ff7330
a419ffcf501134faed24253ccc83e6c71f9659f9
c3e41153ac92f6ef92414024a8386d4ceec2615c
42a452d54c8a25f9f415fef8cf9e3a5c64b7a46a
a7b5f2ef39543f047f587d778579a958bbd0be45
44f7363fbe48d516112cb5bcaabf3778b665f800
6fefb924136da4814e96525dd6b2d73a523ca5dc
0c2aafec33fbd3418dc731c987f43573a7610439
188168c476eabe99764634db8d78eb3f9ea2a927
---
## Ref: https://github.com/spack/spack/commit/[hash]
## [hash]: [description]
## b5ef5c2eb5145020f9de1bcb964626ce6ac2d02e: geant4: version bumps for Geant4 11.1.0
## 99056e03bd3e903b222e300636ec484d85d4b3fb: acts: new versions 19.11.0, 21.0.0, 21.1.0
## f3f8b31be54280c6ef0b5f95ab85604aba3dff30: XRootD: add checksum + patch for 5.5.1 
## 0ea81affd18820933640279bbc687038b3296a4e: py-torch: fix build with gcc@12:
## dceb4c9d655d0529e112b8929558be60973b39f7: Update PyTorch ecosystem
## f2b0c1deab87da3b5aa4c1f2ef4d6af06fa4e32d: py-minkowskiengine: new package (sparse tensor autodiff by Nvidia)
## 2f057d729da61e8c12828df44377f0a93fed820f: py-scipy: add v1.9
## 39a1f1462b0abf12dfaccd33f84142c852c4b56e: SIP build system: fix "python not defined in builder"
## 4b12d015e1c316b4837e02ae37e2c69a8a647180: py-jinja2-cli: new package
## f83d47442dade012b1019840181b8dd459fd8edd: dd4hep: depends_on root +x +opengl when +utilityapps
## 7f1467e795b1cab8b4855e019910c509896ea0e1: dd4hep: new version 1.24, depends_on podio@0.16:
## ebc24b7063ba9a8eb43b4424aac5143cf958d76f: dd4hep: extend conflict on CMake
## a47ebe57841f13239e881ed69eab4949b1d98c32: dd4hep: new versions 1.25, 1.25.1
## ab999d5af90f1bff644b5134bb370b2716e1bcf0: dd4hep: depends_on root +webgui when +ddeve ^root @6.28:
## 62da76cb5dca4d52c43bee06230cca6a5882f05d: directives: depends_on should not admit anonymous specs
## cc2ae9f270befa554ba8b09c68e89bb8248ea650: Add a "maintainer" directive
## ae98d2ba2fcefa9d027e2d6ccc6e7558a32e7228: Support packages for using scitokens on OSG
## ae189cfab8d9036e8d39bbd3f1b61b400d1fcd5b: geant4: new version 11.1.1
## 3afe6f1adcc24335cbca9a9c03ffea188f802766: ROOT: add math/gsl conflict and change version-dependent features to conditional variants
## 559c3de213707b5d52d899fd0382495f2cc8508d: ROOT: new versions and associated dependency constraints
## 8e84dcd7ef999e2659822b34372515175f1723c4: root: new version 6.28.00
## 65bd9b9ac556480b4a9dcc60f7539492af195d4a: podio, edm4hep: add v0.7.2 and v0.16.1 respectively
## 1a32cea11495cbdd699fea4fe622babab83e630d: podio: add v0.16.2
## 6edc4807369a05786e36f63b5d959588ae94a1fa: podio: Add version 0.16.3
## af74680405c931dab16c6674f9b97a32bf3f1122: depfile: improve tab completion
## 0a952f8b7bf6f70009dd5821bccbaf9170c73d07: docs updates for spack env depfile
## f050b1cf7835fd31992b020e1061c52294ff7330: depfile: variable with all identifiers
## a419ffcf501134faed24253ccc83e6c71f9659f9: osg-ca-certs: igtf link should point to version, not 'current'
## c3e41153ac92f6ef92414024a8386d4ceec2615c: Package requirements: allow single specs in requirement lists
## 42a452d54c8a25f9f415fef8cf9e3a5c64b7a46a: estarlight, dpmjet: new packages
## a7b5f2ef39543f047f587d778579a958bbd0be45: Add the very first version of cernlib package
## 44f7363fbe48d516112cb5bcaabf3778b665f800: cernlib: depends_on libxaw libxt
## 6fefb924136da4814e96525dd6b2d73a523ca5dc: cernlib: depends_on freetype, libnsl, libxcrypt, openssl; and patch
## 0c2aafec33fbd3418dc731c987f43573a7610439: cernlib: depends_on openssl when platform=linux
## 188168c476eabe99764634db8d78eb3f9ea2a927: podio: Add 0.16.5 tag
