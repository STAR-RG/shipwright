FROM resin/rpi-raspbian:jessie

RUN apt-get update && apt-get install -y --no-install-recommends \
  apt-utils wget unzip build-essential cmake pkg-config \
  libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev \
  libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
  libxvidcore-dev libx264-dev \
  libgtk2.0-dev libgtk-3-dev \
  libatlas-base-dev gfortran \
  python3-dev python3-pip python-pip python3-h5py \
  python3-numpy python3-matplotlib python3-scipy python3-pandas 

WORKDIR autonomous

COPY . .

# https://github.com/samjabrahams/tensorflow-on-raspberry-pi/releases
RUN wget https://github.com/samjabrahams/tensorflow-on-raspberry-pi/releases/download/v1.1.0/tensorflow-1.1.0-cp34-cp34m-linux_armv7l.whl
# RUN cp  tensorflow-1.1.0-cp34-cp34m-linux_armv7l.whl  tensorflow-1.1.0-cp35-cp35m-linux_armv7l.whl

RUN pip3 install  tensorflow-1.1.0-cp34-cp34m-linux_armv7l.whl 

RUN pip3 install mock
RUN pip install platformio

RUN pip3 install -r requirements.txt

# TODO: upload Arduino code to car

# TODO: add default weigths

RUN echo  "Done"
