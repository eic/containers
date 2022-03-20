from spack import *
from spack.pkg.builtin.edm4hep import Edm4hep as BuiltinEdm4hep


class Edm4hep(BuiltinEdm4hep):
    version('0.4.1', sha256='122987fd5969b0f1639afa9668ac5181203746d00617ddb3bf8a2a9842758a63')
    version('0.4', sha256='bcb729cd4a6f5917b8f073364fc950788111e178dd16b7e5218361f459c92a24')
