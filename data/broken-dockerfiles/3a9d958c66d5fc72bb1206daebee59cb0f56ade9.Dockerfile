FROM ubuntu:14.04

# Install binary dependencies
RUN apt-get -qqy update && \
    apt-get install -qqy software-properties-common --no-install-recommends && \
    apt-add-repository -y ppa:ubuntugis/ppa && \
    apt-get install -qqy \
        wget \
        build-essential \
        gdal-bin \
        libgdal-dev \
        libspatialindex-dev \
        python \
        python-dev \
        python-pip \
        python-tk \
        idle \
        python-pmw \
        python-imaging \
        python-opencv \
        python-matplotlib \
        git-all \
        --no-install-recommends

#RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
#    wget --quiet https://repo.continuum.io/archive/Anaconda2-4.0.0-Linux-x86_64.sh -O ~/anaconda.sh && \
#    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
#    rm ~/anaconda.sh


RUN apt-add-repository ppa:ubuntugis/ubuntugis-unstable

RUN apt-get update

RUN apt-get -qqy install python-gdal

RUN pip install geojson && \
    pip install shapely && \
    pip install ipython && \
    pip install jupyter && \
    pip install pandas && \
    pip install tifffile && \
    pip install awscli --ignore-installed six

# Clean-up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

