from spack import *
from spack.pkg.builtin.gaudi import Gaudi as BuiltinGaudi
class Gaudi(BuiltinGaudi):
    version('36.4', sha256='1a5c27cdc21ec136b47f5805406c92268163393c821107a24dbb47bd88e4b97d')
    version('36.3', sha256='9ac228d8609416afe4dea6445c6b3ccebac6fab1e46121fcc3a056e24a5d6640')
    version('36.2', sha256='a1b4bb597941a7a5b8d60382674f0b4ca5349c540471cd3d4454efbe7b9a09b9')
    version('36.1', sha256='9f718c832313676249e5c3ac76ba4346978ee2328f8cdcb29176498b080402e9')
