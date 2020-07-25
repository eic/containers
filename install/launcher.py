#!/usr/bin/env python3

'''
Generic launcher script to launch applications in this container.

The launcher script calls the desired executable from the singularity image.
As the new images have the environment properly setup, we can accomplish this
without using any wrapper scripts.

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
    echo -e ${{piped_args}} | singularity exec {bind} {container} {exe} $@
else
    singularity exec {bind} {container} {exe} $@
fi
'''

def _write_script(path, content):
    print(' - creating', path)
    with open(path, 'w') as file:
        file.write(content)
    os.system('chmod +x {}'.format(path))
    
def make_launcher(app, container, bindir, 
                  bind='', exe=None):
    '''Configure and install a launcher.

    Arguments:
        - app: our application
        - container: absolute path to container
        - bindir: absolute launcher install path
    Optional:
        - bind: singularity bind directives
        - exe: executable to be associated with app. 
               Default is app.
        - env: environment directives to be added to the wrapper. 
               Multiline string. Default is nothing
    '''
    if not exe:
        exe = app


    ## paths
    launcher_path = '{}/{}'.format(bindir, app)

    ## scripts --> use absolute path for wrapper path inside launcher
    launcher = _LAUNCHER.format(container=container, 
                                bind=bind,
                                exe=exe)

    ## write our scripts
    _write_script(launcher_path, launcher)
