from spack import *
from spack.pkg.builtin.dd4hep import Dd4hep as BuiltinDd4hep


class Dd4hep(BuiltinDd4hep):
    # custom hash for the 2021-07-27 version, needed to include
    # https://github.com/AIDASoft/DD4hep/pull/849
    # https://github.com/AIDASoft/DD4hep/pull/851
    patch('2021-07-27.patch', when='@1.17')
    # patch for https://github.com/AIDASoft/DD4hep/issues/862
    patch('0001-do-not-change-momentum-in-getParticleDirection.patch', when='@1.17:1.18')
    # hack to fix refcount underflow
    patch('refcount_underflow.patch', when='@1.17:')
    patch('pdg.patch', when='@1.17:')
