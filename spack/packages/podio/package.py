from spack import *
from spack.pkg.builtin.podio import Podio as BuiltinPodio


class Podio(BuiltinPodio):
    # issue with build breaking for spack as the search-and-replace for "root"
    # erroneously selects the all files as the build happens under /tmp/root
    patch('cmake.patch', when="@0.13.1:0.14.0")

    version('0.14.1', sha256='361ac3f3ec6f5a4830729ab45f96c19f0f62e9415ff681f7c6cdb4ebdb796f72')
    
    def setup_run_environment(self, env):
        env.prepend_path('PYTHONPATH', self.prefix.python)
        env.prepend_path('LD_LIBRARY_PATH', self.spec['podio'].libs.directories[0])

    def setup_dependent_build_environment(self, env, dependent_spec):
        env.prepend_path('PYTHONPATH', self.prefix.python)
        env.prepend_path('LD_LIBRARY_PATH', self.spec['podio'].libs.directories[0])
        env.prepend_path('ROOT_INCLUDE_PATH', self.prefix.include)
