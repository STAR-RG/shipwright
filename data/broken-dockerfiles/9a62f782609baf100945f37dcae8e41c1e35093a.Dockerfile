FROM ubuntu:18.10

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONIOENCODING=utf-8

# install packages
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y python3-pip
RUN apt-get install -y python3-opencv
RUN apt-get install -y python3-tk
RUN apt-get install -y python3-pyqt5
RUN apt-get install -y cmake
RUN apt-get install -y curl
RUN apt-get install -y unzip
RUN pip3 install tensorflow
RUN pip3 install scikit-image

# install VMD-Lifting
RUN curl -L -O https://github.com/errno-mmd/VMD-Lifting/archive/master.zip
RUN unzip master.zip && rm master.zip
RUN mv VMD-Lifting-master vmdl
RUN cd /vmdl && ./setup.sh

CMD ["bash"]

