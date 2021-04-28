# Custom Spack Repository

Extra spack repository with EIC-related packages and overrides. 

## How to load this repository
To load the repository, clone and then load with spack:
```bash
spack clone https://eicweb.phy.anl.gov/containers/eic_container.git
spack repo add eic_contaienr/spack
```

Then use spack as you normally would.

## Packages
  * New packages
    - `dawn`: A tool to visualize detector geometries.
    - `dawncut`: A tool to edit detector visualizations.
  * Package overrides
    * `acts`: Add version 8.0 and 8.1
    * `fmt`: Modified compiler flags to build shared library version.
    * `madx`: Add madx package
    * `mesa`: fix issue in meson step
    * `qt`: Added gcc10.patch to fix issues compiling QT with gcc10
    * `root`: Re-enabled http module as this builds fine on modern Linux systems and we use this heavily.



