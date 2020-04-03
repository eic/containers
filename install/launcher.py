#!/usr/bin/env python3

'''
Generic launcher script to launch applications in this container.

The launcher script fires off an auxilary wrapper script in the container,
responsible to correctly setup the environment and then launch the application
of choice.

Authors:
    - Whitney Armstrong <warmstrong@anl.gov>
    - Sylvester Joosten <sjoosten@anl.gov>
'''

import os

## generic launcher bash script to launch the application
_LAUNCHER='''#!/usr/bin/env bash

## Boilerplate to make pipes work
piped_args=
if [ -p /dev/stdin ]; then
  # If we want to read the input line by line
  while IFS= read line; do
    if [ -z "$piped_args" ]; then
      piped_args="${{line}}"
    else 
      piped_args="${{piped_args}}\n${{line}}"
    fi
  done
fi

## Fire off the application wrapper
if [ ${{piped_args}} ]  ; then
    echo -e ${{piped_args}} | singularity exec {bind} {container} {wrapper} $@
else
    singularity exec {bind} {container} {wrapper} $@
fi
'''

## Wrapper script called from within the container that loads the propper environment and
## to then actually call our app
_WRAPPER='''#!/usr/bin/env bash

## setup container environment
{env}

## Boilerplate to make pipes work
piped_args=
if [ -p /dev/stdin ]; then
  # If we want to read the input line by line
  while IFS= read line; do
    if [ -z "$piped_args" ]; then
      piped_args="${{line}}"
    else 
      piped_args="${{piped_args}}\n${{line}}"
    fi
  done
fi

## Launch the exe
if [ ${{piped_args}} ]  ; then
    echo -e ${{piped_args}} | {exe} $@
else
    {exe} $@
fi
'''

def _write_script(path, content):
    print(' - creating', path)
    with open(path, 'w') as file:
        file.write(content)
    os.system('chmod +x {}'.format(path))
    
def make_launcher(app, container, bindir, 
                  bind='', libexecdir=None, exe=None, env=''):
    '''Configure and install a launcher/wrapper pair.

    Arguments:
        - app: our application
        - container: absolute path to container
        - bindir: absolute launcher install path
    Optional:
        - bind: singularity bind directives
        - libexecdir: absolute wrapper install path. 
                      Default is bindir.
        - exe: executable to be associated with app. 
               Default is app.
        - env: environment directives to be added to the wrapper. 
               Multiline string. Default is nothing
    '''
    ## assume bindir and libexecdir exist, are absolute, and are writable
    if libexecdir is None:
        libexecdir = bindir

    ## actual exe we want to run, default: same as app
    exe=app
    
    ## paths
    launcher_path = '{}/{}'.format(bindir, app)
    wrapper_path = '{}/{}_wrap'.format(libexecdir, app)

    ## scripts --> use absolute path for wrapper path inside launcher
    launcher = _LAUNCHER.format(container=container, 
                                bind=bind,
                                wrapper=wrapper_path)
    wrapper = _WRAPPER.format(env=env, exe=exe)

    ## write our scripts
    _write_script(launcher_path, launcher)
    _write_script(wrapper_path, wrapper)
