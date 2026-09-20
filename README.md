EIC Software Environment Container
==================================

## Installation Instructions

For installation instructions of `eic-shell`, see https://github.com/eic/eic-shell.

## Updating a package

### An individual package is updated on spack package repository along with a spack version upgrade
This situation just requires modifying the [`spack-environment/packages.yaml`](spack-environment/packages.yaml) file.

#### An individual package is updated on spack package repository after a spack version upgrade

This circumstance requires special cherry pick.

Example:
https://eicweb.phy.anl.gov/containers/eic_container/-/merge_requests/879/diffs

In this example, the spack package xrootd had the latest version 5.6.9 which was put in after a spack version upgrade. We had to add the commit hash of that version update from the upstream [spack](https://github.com/spack/spack/commits/develop/var/spack/repos/builtin/packages/xrootd/package.py) package repository to the cherry-pick list in [`spack-packages.sh`](spack-packages.sh), in addition to modifying [`spack-environment/packages.yaml`](spack-environment/packages.yaml).
