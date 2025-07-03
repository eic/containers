#!/bin/bash

## Prepend /.singularity.d/libs to LD_LIBRARY_PATH (set by singularity --nv)
export LD_LIBRARY_PATH="/.singularity.d/libs:$LD_LIBRARY_PATH"