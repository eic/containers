FROM  eicweb.phy.anl.gov:4567/containers/image_recipes/dd4hep_base:latest

LABEL maintainer="Whitney Armstrong <warmstrong@anl.gov>" \
      name="eic_container" \
      group="containers/eic_container" \
      march="native" \
      basedist="ubuntu" \
      base="dd4hep_base"

ENV PYTHONPATH="/usr/local/lib:${PYTHONPATH}"                            
#RUN source /usr/local/bin/thisroot.sh                                                     \

RUN cd /tmp \
    && apt-get update && apt-get install -y libtbb-dev libtbb2  \
    && wget http://lcgapp.cern.ch/project/simu/HepPDT/download/HepPDT-3.04.01.tar.gz \
    && tar -zxf HepPDT-3.04.01.tar.gz \
    && cd HepPDT-3.04.01 \
    && ./configure && make -j30 && make install \
    && cd /tmp  && rm -r HepPDT-3.04.01

RUN cd /tmp \
      && git clone https://gitlab.cern.ch/hepmc/HepMC3.git  \
      && mkdir HepMC3/build && cd HepMC3/build \
      && cmake ../. -DHEPMC3_ENABLE_ROOTIO=ON -DCMAKE_INSTALL_PREFIX=/usr/local -DHEPMC3_BUILD_EXAMPLES=ON \
      && make -j20 \
      && make install  \
      && cd /tmp && rm -rf /tmp/HepMC3

RUN cd /tmp \
      && apt-get update && sudo apt-get install -y rsync \
      && wget http://home.thep.lu.se/~torbjorn/pythia8/pythia8244.tgz \
      && tar -zxf pythia8244.tgz && cd pythia8244 \
      && ./configure --prefix=/usr/local --enable-shared --enable-64bit --with-root --with-hepmc3 \
      && make -j30 \
      && make install  \
      && cd /tmp && rm -rf /tmp/pythia8244



RUN cd /tmp \
      && git clone  https://github.com/acts-project/acts.git \
      && source /usr/local/bin/thisroot.sh \
      && source /usr/local/bin/geant4.sh \
      && source /usr/local/bin/thisdd4hep.sh \
      && mkdir -p acts/build && cd acts/build \
      && cmake ../. -DCMAKE_INSTALL_PREFIX=/usr/local  \
                    -DCMAKE_CXX_STANDARD=17  \
                    -DACTS_BUILD_DD4HEP_PLUGIN=ON  \
                    -DACTS_BUILD_TGEO_PLUGIN=ON  \
                    -DACTS_BUILD_JSON_PLUGIN=ON  \
                    -DACTS_BUILD_IDENTIFICATION_PLUGIN=ON  \
                    -DACTS_BUILD_FATRAS=ON  \
                    -DACTS_BUILD_DIGITIZATION_PLUGIN=ON \
      && make -j30  && make -j4 install \
      && cd /tmp && rm -rf /tmp/acts 

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

RUN cd /tmp \
      && git clone https://eicweb.phy.anl.gov/eic_tools/GenFit.git \
      && mkdir -p /tmp/GenFit/build \
      && cd /tmp/GenFit/build \
      && cmake ../.  -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_CXX_STANDARD=17 \
      && make -j4  \
      && make -j4 install \
      && cd /tmp && rm -rf /tmp/GenFit

RUN cd /tmp && git clone https://eicweb.phy.anl.gov/EIC/GenFind.git \
      && mkdir -p /tmp/GenFind/build \
      && cd /tmp/GenFind/build \
      && cmake ../.  -DCMAKE_CXX_STANDARD=17 \
      && make VERBOSE=1 \
      && make -j4 install  \
      && cd /tmp && rm -rf /tmp/GenFind


RUN cd /tmp             \
      && git clone  https://eicweb.phy.anl.gov/EIC/NPDet.git \
      && source /usr/local/bin/thisroot.sh \
      && source /usr/local/bin/geant4.sh \
      && source /usr/local/bin/thisdd4hep.sh \
      && mkdir -p NPDet/build && cd NPDet/build \
      && cmake ../. -DCMAKE_INSTALL_PREFIX=/usr/local  -DCMAKE_CXX_STANDARD=17 \
      && make -j30  && make -j4 install \
      && cd /tmp && rm -rf /tmp/NPDet 



