# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Madx(CMakePackage):
    """MAD-X (Methodical Accelerator Design) is an application
    for designing particle accelerators."""

    homepage = "https://github.com/MethodicalAcceleratorDesign/MAD-X"
    url      = "https://github.com/MethodicalAcceleratorDesign/MAD-X/archive/refs/tags/5.07.00.tar.gz"
    git      = "https://github.com/MethodicalAcceleratorDesign/MAD-X.git"

    maintainers = ['wdconinc']

    # Supported MAD-X versions
    version('master', branch='master')
    version('5.07.00', sha256='77c0ec591dc3ea76cf57c60a5d7c73b6c0d66cca1fa7c4eb25a9071e8fc67e60')
    version('5.06.01', sha256='cd2cd9f12463530950dab1c9a26730bb7c38f378c13afb7223fb9501c71a84be')

    # patch for gcc-11 to avoid error due to variable shadowing
    patch('https://github.com/MethodicalAcceleratorDesign/MAD-X/commit/e7a434290df675b894f70026ce0c7c217330cce5.patch',
          sha256='ba9d00692250ab1eeeb7235a4ba7d899ecbbb4588f3ec08afc22d228dc1ea437',
          when='@:5.07.00')

    depends_on("libx11")
    depends_on("zlib")
