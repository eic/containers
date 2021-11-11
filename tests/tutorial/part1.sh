#!/bin/bash
set -Euo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

source /opt/detector/setup.sh

git clone https://eicweb.phy.anl.gov/EIC/tutorials/ip6_tutorial_1.git part1
pushd part1
cmake -B build -S . -DCMAKE_INSTALL_PREFIX=$ATHENA_PREFIX -DCMAKE_CXX_STANDARD=17
cmake --build build -j4 -- install
dd_web_display --export gem_tracker.xml
checkOverlaps -t 0.0001 -c gem_tracker.xml
npdet_info dump gem_tracker.xml
npsim  --runType run  --enableG4GPS \
   --macroFile gps.mac \
   --compactFile ./gem_tracker.xml \
   --outputFile gem_tracker_sim.root

root -b -q scripts/tutorial1_hit_position.cxx+
root -b -q scripts/tutorial2_cell_size.cxx+
popd
