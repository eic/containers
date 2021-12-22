from spack import *
from spack.pkg.builtin.podio import Podio as BuiltinPodio


class Podio(BuiltinPodio):
    # issue with build breaking for spack as the search-and-replace for "root"
    # erroneously selects the all files as the build happens under /tmp/root
    patch('cmake.patch', when="@0.13.1:0.14")
