#!/usr/bin/env python3

## eic_container: Argonne Universal EIC Container

'''
Utility functions for this container

Authors:
    - Whitney Armstrong <warmstrong@anl.gov>
    - Sylvester Joosten <sjoosten@anl.gov>
'''

import os

class InvalidArgumentError(Exception):
    pass

def smart_mkdir(dir):
    '''functions as mkdir -p, with a write-check.
    
    Raises an exception if the directory is not writeable.
    '''
    if not os.path.exists(dir):
        try:
            os.makedirs(dir)
        except Exception as e:
            print('ERROR: unable to create directory', dir)
            raise e
    if not os.access(dir, os.W_OK):
        print('ERROR: We do not have the write privileges to', dir)
        raise InvalidArgumentError()

def project_version():
    '''Return the project version based on the current git branch/tag.'''
    ## Shell command to get the current git version
    git_version_cmd = 'git symbolic-ref -q --short HEAD || git describe --tags --exact-match'
    ## Strip will remove the leading \n character
    return os.popen(git_version_cmd).read().strip()
