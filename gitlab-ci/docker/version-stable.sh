#!/bin/bash

## print the stable version tag for this version to the console

VERSION=`head -n1 ../../VERSION`
echo "${VERSION%.*}-stable"
