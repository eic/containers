## Spack organization and repository, e.g. spack/spack
variable "SPACK_ORGREPO" { default = "spack/spack" }

## Spack github version, e.g. v0.18.1 or commit hash
## note: nightly builds will use e.g. releases/v0.19
## note: update mirrors.yaml.in to match
variable "SPACK_VERSION" { default = "v0.23.0" }

## Space-separated list of spack cherry-picks
variable "SPACK_CHERRYPICKS" {
  default = [
    "09f75ee426a2e05e0543570821582480ff823ba5", # setup-env.sh: if exe contains qemu, use /proc/$$/comm instead
    "b90ac6441cfdf6425cb59551e7b0538899b69527", # celeritas: remove ancient versions and add CUDA package dependency
  ]
}
## Optional hash table with comma-separated file list
variable "SPACK_CHERRYPICKS_FILES" {
  default = []
}
