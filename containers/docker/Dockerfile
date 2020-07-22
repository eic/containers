FROM  eicweb.phy.anl.gov:4567/containers/image_recipes/dd4hep_base:latest

LABEL maintainer="Whitney Armstrong <warmstrong@anl.gov>" \
      name="eic_container" \
      group="containers/eic_container" \
      march="native" \
      basedist="ubuntu" \
      base="dd4hep_base"

ENV PYTHONPATH="/usr/local/lib:${PYTHONPATH}"                            
#RUN source /usr/local/bin/thisroot.sh                                                     \

COPY HepPDT-3.04.01.tar.gz /tmp/HepPDT-3.04.01.tar.gz
RUN cd /tmp \
    && apt-get update && apt-get install -y libtbb-dev libtbb2  \
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
      && apt-get update && apt-get install -y rsync \
      && wget http://home.thep.lu.se/~torbjorn/pythia8/pythia8244.tgz \
      && tar -zxf pythia8244.tgz && cd pythia8244 \
      && ./configure --prefix=/usr/local --enable-shared --enable-64bit --with-root --with-hepmc3 \
      && make -j30 \
      && make install  \
      && cd /tmp && rm -rf /tmp/pythia8244

RUN apt-get update && apt-get remove -y libtbb-dev libtbb2   \
      && cd /tmp \
      && git clone https://eicweb.phy.anl.gov/eic_tools/DD4hep.git \
      && source /usr/local/bin/thisroot.sh \
      && source /usr/local/bin/geant4.sh \
      && mkdir -p DD4hep/build && cd DD4hep/build \
      && cmake ../. -DCMAKE_INSTALL_PREFIX=/usr/local  \
                    -DCMAKE_CXX_STANDARD=17  \
                    -DDD4HEP_USE_GEANT4=ON \
                    -DDD4HEP_USE_HEPMC3=ON \
      && make -j30  && make -j4 install \
      && cd /tmp && rm -rf /tmp/DD4hep  \
      && apt-get update && apt-get install -y libtbb-dev libtbb2  \
      && apt-get clean -y 
 


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

RUN cd /tmp  \
      && apt-get install -y libtbb-dev \
      && pip3 install six \
      && source /usr/local/bin/thisroot.sh \
      && source /usr/local/bin/geant4.sh \
      && source /usr/local/bin/thisdd4hep.sh \
      && git clone https://eicweb.phy.anl.gov/eic_tools/gaudi.git \
      && mkdir -p gaudi/build && cd gaudi/build \
      && cmake --version \
      && cmake ../. -DBoost_NO_BOOST_CMAKE=TRUE  \
              -DCMAKE_INSTALL_PREFIX=/usr/local  \
              -DGAUDI_USE_SYSTEM_CPP_GSL=OFF \
              -DGAUDI_USE_SYSTEM_RANGES_V3=OFF \
              -DCMAKE_CXX_STANDARD=17 \
      && make -j3  && make -j4 install \
      && cd /tmp && rm -rf /tmp/gaudi 




