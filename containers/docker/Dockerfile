FROM  eicweb.phy.anl.gov:4567/containers/image_recipes/dd4hep_base:latest

LABEL maintainer="Whitney Armstrong <warmstrong@anl.gov>" \
      name="eic_container" \
      group="containers/eic_containers" \
      march="native" \
      basedist="ubuntu" \
      base="dd4hep_base"


ENV EPICS_ROOT="/usr/local/epics"                                         \
    EPICS_BASE="/usr/local/epics/base"                                     \
    PYTHONPATH="/usr/local/lib:${PYTHONPATH}"                              \
    EPICS_HOST_ARCH="linux-x86_64"                                         \
    PATH="${EPICS_ROOT}/bin:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}:${PATH}:" \
    LD_LIBRARY_PATH="${EPICS_ROOT}/lib:${EPICS_BASE}/bin/${EPICS_HOST_ARCH}:${LD_LIBRARY_PATH}"

#RUN source /usr/local/bin/thisroot.sh                                                     \
#      && echo "  -------------------------------------------------"                            \
#      && echo "  0. Installing project dependencies"                                           \
#      && echo "  -------------------------------------------------"                            \
#      && apt-get install libtbb-dev libtbb2                                                    \
#      && sed -i 's/\/tmp\/builds\/root_build\/lib\/libtbb.so/\/usr\/local\/lib\/libtbb.so/g'   \
#          /usr/local/cmake/ROOTConfig-targets.cmake                                             \
#      && echo "  -------------------------------------------------"                                \
#      && echo "  1. Installing project library: libfmt"                                            \
#      && echo "  -------------------------------------------------"                                \
#      && echo " spdlog now in base image"
#
#RUN echo "  -------------------------------------------------"                      \
#  && echo "  2. Installing project library: nlohmann/json"                             \
#  && echo "  -------------------------------------------------"                        \
#  && source /usr/local/bin/thisroot.sh                                                 \
#  && echo "  -------------------------------------------------"                        \
#  && echo "  3. Installing: eic/EVIO"                                               \
#  && echo "  -------------------------------------------------"                        \
#  && cd /tmp                                                                           \
#  && git clone https://eicweb.phy.anl.gov/jlab/hallc/analyzer_software/eic_evio.git \
#  && cd eic_evio && git checkout v4.4.6                                          \
#  && mkdir build && cd build                                                        \
#  && cmake ../.  && make -j20 && make install                                       \
#  && cd /tmp && rm -rf eic_evio                                                     \
#  && echo "  -------------------------------------------------"                        \
#  && echo "  4. Installing: Coda/ET"                                                   \
#  && echo "  -------------------------------------------------"                        \
#  && cd /tmp                                                                           \
#  && git clone https://eicweb.phy.anl.gov/jlab/coda/et.git                             \
#  && cd et && git checkout v12.0.1                                                \
#  && mkdir build && cd build                                                      \
#  && cmake ../. -DINSTALL_LMOD_FILES=OFF && make -j20 && make install             \
#  && cd /tmp && rm -rf et
#
#RUN echo "  -------------------------------------------------"                        \
#  && echo "  5. Installing: Podd"                                                      \
#  && echo "  -------------------------------------------------"                        \
#  && cd /tmp                                                                           \
#  && ls -lrth /usr/local/lib/cmake/* \
#  && ls -lrth /usr/local/lib/cmake/spdlog * \
#  && git clone https://eicweb.phy.anl.gov/jlab/hallc/analyzer_software/analyzer.git    \
#  && cd analyzer && git checkout v1.8.2                                           \
#  && mkdir build && cd build                                                      \
#  && cmake ../.  && make -j20 && make install                                     \
#  && cd /tmp  && rm -rf analyzer
#
#RUN echo "  -------------------------------------------------"                            \
#  && echo "  6. Installing: hcana"                                                           \
#  && echo "  -------------------------------------------------"                              \
#  && source /usr/local/bin/thisroot.sh                                                 \
#  && cd /tmp && rm -rf hcana                                                                 \
#  && git clone https://eicweb.phy.anl.gov/jlab/hallc/analyzer_software/hcana.git             \
#  && cd hcana && git checkout v1.2.0                                                    \
#  && mkdir build && cd build                                                            \
#  && cmake ../.  && make -j20 && make install                                           \
#  && cd /tmp && rm -rf hcana                                                                 \
#  && echo "  -------------------------------------------------"                              \
#  && echo "  7. Installing: hconline"                                                        \
#  && echo "  -------------------------------------------------"                              \
#  && cd /tmp && rm -rf hconline                                                              \
#  && git clone https://eicweb.phy.anl.gov/jlab/hallc/analyzer_software/hconline.git          \
#  && cd hconline && git checkout v1.1.7                                                 \
#  && mkdir build && cd build                                                            \
#  && cmake ../.  && make -j20 && make install                                           \
#  && cd /tmp && rm -rf hconline
#
#RUN  cd /tmp \
#  && echo "  -------------------------------------------------"                              \
#  && echo "  8. Installing: hallc_tools"                                                     \
#  && echo "  -------------------------------------------------"                              \
#  && cd /tmp \
#  && git clone --depth=1 --branch 0.9.1 https://github.com/ericniebler/range-v3.git \
#  && mkdir -p range-v3/build && cd range-v3/build \
#  && cmake ../. -DRANGE_V3_PERF=OFF -DRANGE_BUILD_CALENDAR_EXAMPLE=OFF \
#  -DBUILD_TESTING=OFF -DRANGE_V3_EXAMPLES=OFF \
#  -DRANGE_V3_TESTS=OFF -DRANGE_V3_DOCS=OFF \
#  -DRANGES_CXX_STD=17    \
#  && make -j8 install \
#  && cd /tmp && rm -r range-v3 \
#  && git clone https://eicweb.phy.anl.gov/jlab/hallc/analyzer_software/hallc_tools.git       \
#  && cd hallc_tools && git checkout v1.1.9                                                   \
#  && mkdir build && cd build                                                                 \
#  && cmake ../.  && make -j20 && make install                                                \
#  && cd /tmp && rm -rf hallc_tools                                                           \ 
#  && echo "  -------------------------------------------------"                              \
#  && echo "  10. Slimming down image"                                                        \
#  && echo "  -------------------------------------------------"                              \
#  && apt-get clean                                                                           \
#  && rm -rf /var/lib/apt/lists/*                                                             \
#  && echo "  -------------------------------------------------"                              
#
##  && echo "  9. Installing: simc"                                                           \
##  && echo "  -------------------------------------------------"                             \
##  && cd /tmp
##  git clone --recurse-submodules https://eicweb.phy.anl.gov/jlab/hallc/simulation/simc-file-input.git \
##    && cd simc-file-input && git checkout v1.0.0 && cd -                                               \
##    mkdir build && cd build && cmake ../simc-file-input && make -j4 install                            \
##  cd /tmp && rm -rf build simc-file-input                                                              \
##  echo "  -------------------------------------------------"                                           \
##  echo "  ===> Image setup complete"                                                                   \
##  echo "  -------------------------------------------------"                                           \
