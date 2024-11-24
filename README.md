EIC Software Environment Container
==================================

## Installation Instructions 

For installation instructions of `eic-shell`, see https://github.com/eic/eic-shell.

## Updating a package

### An individual package is updated on spack package repository along with a spack version upgrade
This situation just requires modifying the eic-shell [yaml](https://eicweb.phy.anl.gov/containers/eic_container/-/blob/master/spack-environment/packages.yaml?ref_type=heads) file.

#### An individual package is updated on spack package repository after a spack version upgrade

This circumstance requires special cherry pick.

Example:
https://eicweb.phy.anl.gov/containers/eic_container/-/merge_requests/879/diffs

In this example, the spack package xrootd had the latest version 5.6.9 which was put in after a spack version upgrade. We had to modify the eic-shell [spack.sh](https://eicweb.phy.anl.gov/containers/eic_container/-/blob/master/spack-environment/packages.yaml?ref_type=heads) file to include the commit hash of the version update from the main [spack](https://github.com/spack/spack/commits/develop/var/spack/repos/builtin/packages/xrootd/package.py) package repository in addition to modifying the eic-shell [yaml](https://eicweb.phy.anl.gov/containers/eic_container/-/blob/master/spack-environment/packages.yaml?ref_type=heads) file.  

