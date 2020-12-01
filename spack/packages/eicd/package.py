from spack import *

class Eicd(CMakePackage):
    '''EICD podio-based data model for the EIC'''

    homepage = 'https://eicweb.phy.anl.gov/EIC/eicd'
    #git      = 'https://eicweb.phy.anl.gov/EIC/NPDet.git'
    #list_url = 'https://eicweb.phy.anl.gov/EIC/NPDet/-/tags'
    maintainers = ['sly2j', 'whit']

    ## Master branch
    version('master', git='https://eicweb.phy.anl.gov/EIC/eicd.git',
                      branch='master',
                      preferred=True)

    variant('cxxstd',
            default='11',
            values=('11', '14', '17'),
            multi=False,
            description='Use the specified C++ standard when building.')

    depends_on('cmake@3.2:', type='build')
    depends_on('podio')
    depends_on('root')

    def cmake_args(self):
        options = []
        ## C++ standard
        options.append('-DCMAKE_CXX_STANDARD={0}'.format(
            self.spec.variants['cxxstd'].value))
        return options
