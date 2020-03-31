#!/usr/bin/env python3

## eic_container: Argonne Universal EIC Container

'''
Install modulefile for this container.

Authors:
    - Whitney Armstrong <warmstrong@anl.gov>
    - Sylvester Joosten <sjoosten@anl.gov>
'''

import os

## Generic module file
_MODULEFILE='''#%Module1.0#####################################################################
##
## for {name} {version}
##
proc ModulesHelp {{ }} {{
    puts stderr "This module sets up the environment for the {name} container"
}}
module-whatis "{name} {version}"

# For Tcl script use only
set version 4.1.4

prepend-path    PATH    {bindir}
'''

def make_modulefile(project, version, moduledir, bindir):
    '''Configure and install a modulefile for this project.

    Arguments:
        - project: project name
        - version: project version
        - moduledir: root modulefile directory
        - bindir: where executables for this project are located
    '''

    ## create our modulefile
    content = _MODULEFILE.format(name=project, version=version, bindir=bindir)
    fname = '{}/{}'.format(moduledir, version)
    print(' - creating', fname)
    with open(fname, 'w') as file:
        file.write(content)
