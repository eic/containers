from spack import *
from spack.pkg.builtin.geant4 import Geant4 as BuiltinGeant4


class Geant4(BuiltinGeant4):
    ## Add to the hardcoded GEANT4 Birk's constants
    patch('birks.patch', when='@10.7.0:')

    version('11.0.1', sha256='fa76d0774346b7347b1fb1424e1c1e0502264a83e185995f3c462372994f84fa')
    version('11.0.0', sha256='04d11d4d9041507e7f86f48eb45c36430f2b6544a74c0ccaff632ac51d9644f1')