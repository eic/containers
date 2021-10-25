#syntax=docker/dockerfile:1.2
ARG INTERNAL_TAG="testing" 

## Make a specific "feature" image, identical to jug_xl except for the detector
## symlinked as default in /opt/detector. Not that these images will be removed
## in the future once we move the detectors already installed in the main
## image.

FROM eicweb.phy.anl.gov:4567/containers/eic_container/jug_xl:${INTERNAL_TAG}

## also install detector/ip geometries into opt
ARG DETECTOR=athena
ARG DETECTOR_BRANCH=canyonlands
RUN rm -rf /opt/detector/{setup.sh,lib,share}                                    \
 && ln -sf /opt/detector/${DETECTOR}-${DETECTOR_BRANCH}/setup.sh                 \
           /opt/detector/setup.sh                                                \
 && ln -sf /opt/detector/${DETECTOR}-${DETECTOR_BRANCH}/lib                      \
           /opt/detector/lib                                                     \
 && ln -sf /opt/detector/${DETECTOR}-${DETECTOR_BRANCH}/share                    \
           /opt/detector/share
