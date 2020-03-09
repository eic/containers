FROM  eicweb.phy.anl.gov:4567/containers/image_recipes/dd4hep_base:latest

LABEL maintainer="Whitney Armstrong <warmstrong@anl.gov>" \
      name="eic_container" \
      group="containers/eic_containers" \
      march="native" \
      basedist="ubuntu" \
      base="dd4hep_base"


ENV PYTHONPATH="/usr/local/lib:${PYTHONPATH}"                            

#RUN source /usr/local/bin/thisroot.sh                                                     \

RUN cd /tmp && git clone https://github.com/GenFit/GenFit.git \
      && mkdir -p /tmp/GenFit/build \
      && cd /tmp/GenFit/build \
      && cmake ../.  \
      && make -j20 \
      && make install 

