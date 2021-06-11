#!/bin/bash

git clone https://eicweb.phy.anl.gov/EIC/detectors/athena.git
git clone https://eicweb.phy.anl.gov/EIC/detectors/ip6.git
ln -s ../ip6/ip6 athena/ip6

echo "PART 1: QUICK START"
pushd athena
source /opt/detector/setup.sh
dd_web_display --export athena.xml
popd
