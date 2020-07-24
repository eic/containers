#!/usr/bin/env python3

## eic_container: Argonne Universal EIC Container

'''
Deploy the singularity container built by the CI for this version of the software.

The current version is determined from the currently loaded git branch or tag,
unless it is explicitly set on the command line.

Authors:
    - Whitney Armstrong <warmstrong@anl.gov>
    - Sylvester Joosten <sjoosten@anl.gov>
'''

import os
import argparse
import urllib.request
from install import make_launcher, make_modulefile
from install.util import smart_mkdir, project_version, InvalidArgumentError

## Gitlab group and project/program name. 
GROUP_NAME='containers'
PROJECT_NAME='eic_container'
IMAGE_ROOT='eic'

PROGRAMS = [('eic_shell', '/usr/bin/bash'),
            'root', 
            'ipython']

## URL for the current container (git tag will be filled in by the script)
CONTAINER_URL = r'https://eicweb.phy.anl.gov/{group}/{project}/-/jobs/artifacts/{version}/raw/build/{img}.sif?job={img}_singularity'

CONTAINER_ENV=r'''source /etc/profile'''

## Singularity bind directive
BIND_DIRECTIVE= '-B {0}:{0}'

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
            'prefix',
            help='Install prefix. This is where the container will be deployed.')
    parser.add_argument(
            '-v', '--version',
            dest='version',
            default=project_version(),
            help='(opt.) project version. Default: current git branch/tag.')
    parser.add_argument(
            '-f', '--force',
            action='store_true',
            help='Force-overwrite already downloaded container',
            default=False)
    parser.add_argument(
            '-b', '--bind-path',
            dest='bind_paths',
            action='append',
            help='(opt.) extra bind paths for singularity.')
    parser.add_argument(
            '-m', '--module-path',
            dest='module_path',
            help='(opt.) Root module path where you want to install a modulefile. D: <prefix>/../../etc/modulefiles')
    parser.add_argument(
            '--install-builder',
            dest='builder',
            help='(opt.) Install fat builder image, instead of normal slim image')

    args = parser.parse_args()

    print('Deploying', PROJECT_NAME, 'version', args.version)

    ## Check if our bind paths are valid
    bind_directive = ''
    if args.bind_paths and len(args.bind_paths):
        print('Singularity bind paths:')
        for path in args.bind_paths:
            print(' -', path)
            if not os.path.exists(path):
                print('ERROR: path', path, 'does not exist.')
                raise InvalidArgumentError()
        bind_directive = ' '.join([BIND_DIRECTIVE.format(path) for path in args.bind_paths])

    ## We want to slightly modify our version specifier: if it leads with a 'v' drop the v
    ## for everything installed, but ensure we have the leading v as well where needed
    version = '{}'.format(args.version)
    vversion = '{}'.format(args.version)
    if version[0] is 'v':
        version = version[1:]
    if vversion[0].isdigit():
        vversion= 'v{}'.format(args.version)

    ## Create our install prefix if needed and ensure it is writable
    args.prefix = os.path.abspath(args.prefix)
    if not args.module_path:
        args.module_path = '{}/etc/modulefiles'.format(args.prefix)
    print('Install prefix:', args.prefix)
    print('Creating install prefix if needed...')
    bindir = '{}/bin'.format(args.prefix)
    libdir = '{}/lib'.format(args.prefix)
    libexecdir = '{}/libexec'.format(args.prefix)
    root_prefix = os.path.abspath('{}/..'.format(args.prefix))
    moduledir = '{}/etc/modulefiles/{}'.format(root_prefix, PROJECT_NAME)
    for dir in [bindir, libdir, libexecdir, moduledir]:
        print(' -', dir)
        smart_mkdir(dir)

    ## At this point we know we can write to our desired prefix and that we have a set of
    ## valid bind paths

    ## Get the container
    ## We want to slightly modify our version specifier: if it leads with a 'v' drop the v
    img = IMAGE_ROOT
    if args.builder:
        img += "_builder"
    container = '{}/{}.sif.{}'.format(libdir, img, version)
    if not os.path.exists(container) or args.force:
        url = CONTAINER_URL.format(group=GROUP_NAME, project=PROJECT_NAME,
                version=vversion, img=img)
        print('Downloading container from:', url)
        print('Destination:', container)
        urllib.request.urlretrieve(url, container)
    else:
        print('WARNING: Container found at', container)
        print(' ---> run with -f to force a re-download')

    make_modulefile(PROJECT_NAME, version, moduledir, bindir)

    ## configure the application launchers
    print('Configuring applications launchers: ')
    for prog in PROGRAMS:
        app = prog
        exe = prog
        if type(prog) == tuple:
            app = prog[0]
            exe = prog[1]
        make_launcher(app, container, bindir,
                      bind=bind_directive,
                      libexecdir=libexecdir,
                      exe=exe,
                      env=CONTAINER_ENV)

    print('Container deployment successful!')
