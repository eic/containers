#!/bin/bash

## print the stable version tag for this version to the console

version=head -n1 ../../VERSION
echo "${VERSION%.*}-stable"
