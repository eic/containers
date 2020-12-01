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
    * `acts`: Added version 3.00.0 which is still missing in the main repo.
    * `dd4hep`: Disabled use of the Ninja backend for cmake as it was running into dependency issues building assymp
    * `fmt`: Modified compiler flags to build shared library version.
    * `geant4`: Added explicit glu dependency for OpenGL
    * `graphviz`: Set upper version limit to stop applying implicit.patch to the newest version
    * `qt`: Added gcc10.patch to fix issues compiling QT with gcc10
    * `root`: Re-enabled http module as this builds fine on modern Linux systems and we use this heavily.



