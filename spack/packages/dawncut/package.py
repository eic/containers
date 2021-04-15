# Copyright 203-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *
import os

class Dawncut(MakefilePackage):
    """DAWNCUT is a tool to generate a 3D scene data clipped with an arbitrary plane.
    It reads a source DAWN-format file and outputs a new DAWN-format data, 
    describing a plane-clipped 3D scene.  The output DAWN-format data can be 
    visualized with Fukui Renderer DAWN.
    """

    # dawn webpage not available anymore
    homepage = "https://geant4.kek.jp/~tanaka"
    url = "http://10.10.241.24/software/dawncut_1_54a.tar.gz"
    maintainers = ['sly2j']

    version('1_54a',
            sha256='17d7ccd2ff863e2f3700cc3e751cfca37a1425abfa0edc3b8f6497d8746ddcf4')

    # FIXME: Add dependencies if required.
    # depends_on('foo')

    ## Patch to add install directive to Makefile
    patch('install.patch')

    def edit(self, spec, prefix):
        makefile = FileFilter("Makefile")
        makefile.filter('CC= .*', 'CC = ' + env['CC'])
        makefile.filter('CXX = .*', 'CXX = ' + env['CXX'])
        os.environ['INSTALL_DIR'] = '{}/bin'.format(prefix)
