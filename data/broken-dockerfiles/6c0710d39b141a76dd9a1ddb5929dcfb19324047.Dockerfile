FROM ubuntu:xenial

RUN mkdir -p /app/spotify-ripper-simple

# INSTALL DEPENDENCIES
RUN apt update
RUN apt upgrade -y
RUN apt install software-properties-common python-software-properties git locales -y --no-install-recommends
RUN apt-add-repository multiverse -y
RUN apt update -y
RUN apt install build-essential automake autoconf wget -y --no-install-recommends
RUN apt install lame libffi-dev -y --no-install-recommends
RUN apt install python-dev python-pip -y --no-install-recommends


# Download, Build and Install libspotify
RUN wget https://developer.spotify.com/download/libspotify/libspotify-12.1.51-Linux-x86_64-release.tar.gz && tar xvf libspotify-12.1.51-Linux-x86_64-release.tar.gz
RUN cd libspotify-12.1.51-Linux-x86_64-release/ && make install prefix=/usr/local


# Install Spotify Ripper from upstream repo and install Python Dependencies using pip
WORKDIR /app
RUN git clone https://github.com/burner420/spotify-ripper.git
WORKDIR /app/spotify-ripper
RUN pip install setuptools wheel
RUN pip install -r requirements.txt
RUN python setup.py install


# Install Webapp
COPY . /app/spotify-ripper-simple
WORKDIR /app/spotify-ripper-simple
RUN pip install -r requirements.txt


ENV PYTHONIOENCODING utf-8
RUN locale-gen en_GB.UTF-8
ENV LANG='en_GB.UTF-8' LANGUAGE='en_GB:en' LC_ALL='en_GB.UTF-8'


WORKDIR /app/spotify-ripper-simple
CMD ./run.sh
