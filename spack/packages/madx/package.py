# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Madx(CMakePackage):
    """
    
    """

    homepage = "https://github.com/MethodicalAcceleratorDesign/MAD-X"
    git      = "https://github.com/MethodicalAcceleratorDesign/MAD-X.git"
    maintainers = ['tpersson']

    tags = ['hep']

    # Supported MAD-X versions
    version('master', branch='master')
    version('5.06.1', commit='f3764bceefb802f6b2a3c35d7d961adf6718d377')

    #variant('benchmarks', default=False, description='Build the performance benchmarks')
    #variant('examples', default=False, description='Build the examples')
    #variant('integration_tests', default=False, description='Build the integration tests')
    #variant('unit_tests', default=False, description='Build the unit tests')

    #variant('autodiff', default=False, description='Build the auto-differentiation plugin')
    #variant('dd4hep', default=False, description='Build the DD4hep plugin')
    #variant('digitization', default=False, description='Build the geometric digitization plugin')
    #variant('fatras', default=False, description='Build the FAst TRAcking Simulation package')
    #variant('identification', default=False, description='Build the Identification plugin')
    #variant('json', default=False, description='Build the Json plugin')
    #variant('legacy', default=False, description='Build the Legacy package')
    ## FIXME: Cannot build ONNX plugin as Spack doesn't have an ONNX runtime
    ## FIXME: Cannot build SyCL plugin yet as Spack doesn't have SyCL support
    #variant('tgeo', default=False, description='Build the TGeo plugin')

    # Variants that only affect Acts examples for now
    #variant('geant4', default=False, description='Build the Geant4-based examples')
    #variant('hepmc3', default=False, description='Build the HepMC3-based examples')
    #variant('pythia8', default=False, description='Build the Pythia8-based examples')

    depends_on("libx11")

    # Build dependencies
    # FIXME: Use spack's autodiff package once there is one
    #depends_on('boost @1.62:1.69.99 +program_options +test', when='@:0.10.3')
    #depends_on('boost @1.69: +filesystem +program_options +test', when='@0.10.4:')
    #depends_on('cmake @3.11:', type='build')
    #depends_on('dd4hep @1.10:', when='+dd4hep')
    #depends_on('dd4hep @1.10: +geant4', when='+dd4hep +geant4')
    #depends_on('eigen @3.2.9:', type='build')
    #depends_on('geant4', when='+geant4')
    #depends_on('hepmc3@3.1:', when='+hepmc3')
    #depends_on('heppdt', when='+hepmc3')
    #depends_on('intel-tbb', when='+examples')
    #depends_on('nlohmann-json @3.2.0:', when='@0.14: +json')
    #depends_on('pythia8', when='+pythia8')
    #depends_on('root @6.10: cxxstd=14', when='+tgeo @:0.8.0')
    #depends_on('root @6.10: cxxstd=17', when='+tgeo @0.8.1:')

    ## Some variant combinations do not make sense
    #conflicts('+autodiff', when='@:1.01')
    #conflicts('+benchmarks', when='@:0.15')
    #conflicts('+dd4hep', when='-tgeo')
    #conflicts('+examples', when='@:0.22')
    #conflicts('+examples', when='-digitization')
    #conflicts('+examples', when='-fatras')
    #conflicts('+examples', when='-identification')
    #conflicts('+examples', when='-json')
    #conflicts('+examples', when='-tgeo')
    #conflicts('+fatras', when='@:0.15')
    #conflicts('+geant4', when='@:0.22')
    #conflicts('+geant4', when='-examples')
    #conflicts('+hepmc3', when='@:0.22')
    #conflicts('+hepmc3', when='-examples')
    #conflicts('+pythia8', when='@:0.22')
    #conflicts('+pythia8', when='-examples')
    #conflicts('+tgeo', when='-identification')
    #conflicts('%gcc@:7', when='@0.23:')

