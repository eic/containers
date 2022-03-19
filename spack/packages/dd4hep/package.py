from spack import *
from spack.pkg.builtin.dd4hep import Dd4hep as BuiltinDd4hep


class Dd4hep(BuiltinDd4hep):
    version('1.20.1', sha256='18c18a125583c39cb808c602e052cc2379aa3a8029aa78dbb40bcc31f1deb798')
    version('1.20', sha256='cf6af0c486d5c84e8c8a8e40ea16cec54d4ed78bffcef295a0eeeaedf51cab59')
    version('1.19', sha256='d2eccf5e8402ba7dab2e1d7236e12ee4db9b1c5e4253c40a140bf35580db1d9b')

    patch('https://github.com/AIDASoft/DD4hep/pull/896.diff',
          sha256='2d7e87824d324b8bd14cb2a8b441d2fc25a6d3474e6e041bd68c56439a9477cf',
          when='@1.20:1.20.1')
