#!/bin/bash

grep "hallac_container VERSION" ../../CMakeLists.txt | sed 's/project (hallac_container VERSION //' | sed 's/)//'

