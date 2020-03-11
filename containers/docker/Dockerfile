FROM  eicweb.phy.anl.gov:4567/containers/image_recipes/dd4hep_base:latest

LABEL maintainer="Whitney Armstrong <warmstrong@anl.gov>" \
      name="eic_container" \
      group="containers/eic_containers" \
      march="native" \
      basedist="ubuntu" \
      base="dd4hep_base"


ENV PYTHONPATH="/usr/local/lib:${PYTHONPATH}"                            

#RUN source /usr/local/bin/thisroot.sh                                                     \

RUN  cd /tmp \
      && source /usr/local/bin/thisroot.sh \
      && source /usr/local/bin/geant4.sh \
      && git clone https://eicweb.phy.anl.gov/EIC/podio.git \
      && mkdir -p podio/build && cd podio/build \
      && cmake ../. -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_CXX_STANDARD=17 \
      && make -j30  && make -j4 install \
      && cd /tmp/podio/lcio2 && mkdir build && cd build \
      && cmake ../. -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_CXX_STANDARD=17 \
      && make -j30  && make -j4 install \
      && cd /tmp/podio/lcio2_tools && mkdir build && cd build \
      && cmake ../. -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_CXX_STANDARD=17 \
      && make -j30  && make -j4 install \
      && cd /tmp && rm -rf /tmp/podio

RUN cd /tmp && git clone https://github.com/GenFit/GenFit.git \
      && mkdir -p /tmp/GenFit/build \
      && cd /tmp/GenFit/build \
      && cmake ../.  -DCMAKE_CXX_STANDARD=17 \
      && make VERBOSE=1 \
      && make install 

RUN cd /tmp && git clone https://eicweb.phy.anl.gov/EIC/GenFind.git \
      && mkdir -p /tmp/GenFind/build \
      && cd /tmp/GenFind/build \
      && cmake ../.  -DCMAKE_CXX_STANDARD=17 \
      && make VERBOSE=1 \
      && make install 


