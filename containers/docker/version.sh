#!/bin/bash

grep "eic_container VERSION" ../../CMakeLists.txt | sed 's/project (eic_container VERSION //' | sed 's/)//'

