FROM tensorflow/tensorflow:1.5.0-py3

RUN apt update &&\
 	apt install --yes libsm6 libxext6 libfontconfig1 libxrender1 python3-tk  python-setuptools libffi-dev cmake zlib1g-dev libjpeg-dev xvfb libav-tools xorg-dev python-opengl libboost-all-dev libsdl2-dev swig git

# Patch install for ALE...
WORKDIR /
RUN git clone https://github.com/openai/atari-py
WORKDIR /atari-py
RUN pip3 install .
WORKDIR /atari-py/atari_py/ale_interface
RUN make

ADD requirements.txt .
RUN pip3 install -r requirements.txt

ADD . /yarlp
WORKDIR /yarlp
RUN python3 setup.py install
RUN pytest yarlp