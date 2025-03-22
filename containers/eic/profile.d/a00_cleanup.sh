#!/bin/bash

## Force environment to be clean
export LD_LIBRARY_PATH="/lib/x86_64-linux-gnu:/usr/local/lib64:/usr/local/lib"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
[ ! -z "$CC" ] && unset CC
[ ! -z "$CXX" ] && unset CXX
[ ! -z "$JUPYTER_CONFIG_DIR" ] && unset JUPYTER_CONFIG_DIR
[ ! -z "$JUPYTER_PATH" ] && unset JUPYTER_PATH
[ ! -z "$CLING_STANDARD_PCH" ] && unset CLING_STANDARD_PCH
[ ! -z "$USER_PATH" ] && unset USER_PATH
[ ! -z "$SHLIB_PATH" ] && unset SHLIB_PATH
[ ! -z "$LIBPATH" ] && unset LIBPATH
[ ! -z "$CMAKE_PREFIX_PATH" ] && unset CMAKE_PREFIX_PATH
[ ! -z "$SOFTWARE_HOME" ] && unset SOFTWARE_HOME
[ ! -z "$ROOTSYS" ] && unset ROOTSYS

# When starting in a (ana|mini)conda virtualenv, CMake prefers that python
[ ! -z "$CONDA_EXE" ] && unset CONDA_EXE
[ ! -z "$CONDA_PREFIX" ] && unset CONDA_PREFIX
[ ! -z "$CONDA_PYTHON_EXE" ] && unset CONDA_PYTHON_EXE
