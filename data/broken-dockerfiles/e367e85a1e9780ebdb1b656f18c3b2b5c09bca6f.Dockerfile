# Dockerfile for text to speech (TTS) based on
# Merlin project (https://github.com/CSTR-Edinburgh/merlin/)
# The Neural Network (NN) based Speech Synthesis System
#
# (c) Abylay Ospan <aospan@jokersys.com>, 2017
# https://jokersys.com
# under GPLv2 license

FROM ubuntu:14.04
MAINTAINER aospan@jokersys.com

ENV USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential cmake git wget python-dev unzip \
  python-numpy python-scipy curl python-tk libatlas3-base libncurses5-dev \
  ca-certificates zlib1g-dev automake autoconf libtool subversion csh gawk && \
  curl -k https://bootstrap.pypa.io/get-pip.py  > get-pip.py && python get-pip.py && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# * compile Merlin tools
# * download and install festival&festvox
# * download festival voices
RUN git clone -b aospan --depth=1 https://github.com/aospan/merlin.git \
  && sudo ln -s -f bash /bin/sh \
  && cd merlin/tools/ && ./compile_tools.sh \
  && wget http://festvox.org/packed/festival/2.4/speech_tools-2.4-release.tar.gz \
  && tar -xvzf speech_tools-2.4-release.tar.gz && rm speech_tools-2.4-release.tar.gz \
  && wget http://festvox.org/packed/festival/2.4/festival-2.4-release.tar.gz \
  && tar -xvzf festival-2.4-release.tar.gz && rm festival-2.4-release.tar.gz \
  && wget http://festvox.org/festvox-2.7/festvox-2.7.0-release.tar.gz \
  && tar -xvzf festvox-2.7.0-release.tar.gz && rm festvox-2.7.0-release.tar.gz \
  && cd speech_tools && ./configure && make \
  && cd ../festival && ./configure && make \
  && cd ../festvox && ./configure && make \
  && cd .. && wget "http://www.cstr.ed.ac.uk/downloads/festival/2.4/festlex_CMU.tar.gz" \
  && tar xvfz festlex_CMU.tar.gz && rm festlex_CMU.tar.gz \
  && wget "http://www.cstr.ed.ac.uk/downloads/festival/2.4/festlex_OALD.tar.gz" \
  && tar xvfz festlex_OALD.tar.gz && rm festlex_OALD.tar.gz \
  && wget "http://www.cstr.ed.ac.uk/downloads/festival/2.4/festlex_POSLEX.tar.gz" \
  && tar xvfz festlex_POSLEX.tar.gz && rm festlex_POSLEX.tar.gz \
  && wget "http://www.cstr.ed.ac.uk/downloads/festival/2.4/voices/festvox_cmu_us_bdl_cg.tar.gz" \
  && tar xvfz festvox_cmu_us_bdl_cg.tar.gz && rm festvox_cmu_us_bdl_cg.tar.gz \
  && find /opt/merlin/tools/ -type f -perm +100 -exec strip {} \; 2>/dev/null \
  && find /opt/merlin/tools/ -type f -perm +100 -exec strip {} \;

# install python modules
RUN pip install Theano lxml matplotlib bandmat

WORKDIR /opt/merlin/egs/slt_arctic/s1/

# download trained NN (or train your own - see next section )
# and prepare config files
RUN mkdir experiments && cd experiments \
  && wget "https://github.com/aospan/merlin-tts/raw/master/bdl_arctic_full.tbz2" \
  && tar xvfjp bdl_arctic_full.tbz2 && rm bdl_arctic_full.tbz2 \
  && cd .. && touch bdl_arctic_full_data.zip && mkdir bdl_arctic_full_data \
  && ./scripts/setup.sh bdl_arctic_full \
  && ./scripts/prepare_config_files.sh conf/global_settings.cfg \
  && ./scripts/prepare_config_files_for_synthesis.sh conf/global_settings.cfg

# Uncomment this if you want to train NN from dataset.
# This can take up to 10 hours on CPU
# * download dataset (bdl male voice) and train NN
#RUN cd /opt/merlin/egs/slt_arctic/s1/ && ./run_full_voice.sh bdl

WORKDIR /opt/merlin
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh ${*}", "--"]

