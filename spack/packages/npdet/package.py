from spack import *

class Npdet(CMakePackage):
    '''NPDet DD4hep detector library for Nuclear Physics.'''

    homepage = 'https://eicweb.phy.anl.gov/EIC/NPDet'
    url      = 'https://eicweb.phy.anl.gov/EIC/NPDet/-/archive/v0.2.0/NPDet-v0.2.0.tar.gz'
    #git      = 'https://eicweb.phy.anl.gov/EIC/NPDet.git'
    #list_url = 'https://eicweb.phy.anl.gov/EIC/NPDet/-/tags'
    maintainers = ['sly2j', 'whit']

    ## Master branch
    version('master', git='https://eicweb.phy.anl.gov/EIC/NPDet.git',
                      branch='master',
                      preferred=True)
    version('0.2.0', sha256='e0e9018e891cd7c195d15f3c0b2e5fc872f140e8ad94f90fbf2b607f10e5688c')

    variant('cxxstd',
            default='11',
            values=('11', '14', '17'),
            multi=False,
            description='Use the specified C++ standard when building.')

    depends_on('cmake@3.2:', type='build')
    depends_on('hepmc3')
    depends_on('dd4hep')
    depends_on('root')
    depends_on('fmt')
    depends_on('spdlog')
    depends_on('podio')

    def cmake_args(self):
        options = []
        ## C++ standard
        options.append('-DCMAKE_CXX_STANDARD={0}'.format(
            self.spec.variants['cxxstd'].value))
        return options
