# shellcheck shell=sh
## Compressed image size caps, in GiB.
##
## A build fails when a final image exceeds its cap here, which catches size
## regressions early (for example an accidentally Spack-built LLVM pulling in
## hundreds of MiB).  Images without an entry are not size-checked.
##
## This file is sourced by both CI systems -- .github/workflows/build-base.yml
## and build-eic.yml, and the base and eic jobs in .gitlab-ci.yml -- so the
## caps are defined once.  Keep it POSIX sh: the GitLab jobs source it from
## busybox ash.  The variables are exported because the GitLab jobs read them
## back with printenv, while the GitHub jobs use bash indirect expansion.
##
## Variable names follow SIZE_LIMIT_<IMAGE NAME UPPERCASED>_GIB, which is how
## every consumer looks them up from the image name it is building.
##
## To raise a cap after an intentional size increase:
##   1. read the published size off the failing job's check_image_size output
##   2. add ~15% headroom and round up
##   3. update the single entry below

export SIZE_LIMIT_DEBIAN_STABLE_BASE_GIB="0.9"
export SIZE_LIMIT_EIC_CI_GIB="3.1"
export SIZE_LIMIT_EIC_XL_GIB="4.7"
export SIZE_LIMIT_EIC_TF_GIB="6.1"
export SIZE_LIMIT_EIC_CUDA_GIB="8.1"
export SIZE_LIMIT_EIC_DEV_CUDA_GIB="10.9"
