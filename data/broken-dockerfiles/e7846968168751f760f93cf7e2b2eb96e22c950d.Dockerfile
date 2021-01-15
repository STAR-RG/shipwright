FROM neurodebian:xenial-non-free
MAINTAINER John Pellman <john.pellman@childmind.org>

# create scratch directories for singularity
RUN mkdir /scratch && mkdir /local-scratch && mkdir -p /code && mkdir -p /cpac_resources

# install wget
RUN apt-get update && apt-get install -y wget curl

# Install the validator
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - && \
     apt-get install -y nodejs && \
     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN npm install -g bids-validator

# Install Ubuntu dependencies
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      cmake \
      git \
      graphviz \
      graphviz-dev \
      gsl-bin \
      libcanberra-gtk-module \
      libexpat1-dev \
      libgiftiio-dev \
      libglib2.0-dev \
      libglu1-mesa \
      libglu1-mesa-dev \
      libjpeg-progs \
      libgl1-mesa-dri \
      libglw1-mesa \
      libxml2 \
      libxml2-dev \
      libxext-dev \
      libxft2 \
      libxft-dev \
      libxi-dev \
      libxmu-headers \
      libxmu-dev \
      libxpm-dev \
      libxslt1-dev \
      m4 \
      make \
      mesa-common-dev \
      mesa-utils \
      netpbm \
      pkg-config \
      tcsh \
      unzip \
      xvfb \
      xauth \
      zlib1g-dev

# Install 16.04 dependencies
RUN apt-get update && \
    apt-get install -y \
      dh-autoreconf \
      libgsl-dev \
      libmotif-dev \
      libtool \
      libx11-dev \
      libxext-dev \
      x11proto-xext-dev \
      x11proto-print-dev \
      xutils-dev

# Compiles libxp- this is necessary for some newer versions of Ubuntu
# where the is no Debian package available.
RUN git clone git://anongit.freedesktop.org/xorg/lib/libXp /tmp/libXp && \
    cd /tmp/libXp && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd / && \
    rm -rf /tmp/libXp

# Installing and setting up c3d
RUN mkdir -p /opt/c3d && \
    curl -sSL "http://downloads.sourceforge.net/project/c3d/c3d/1.0.0/c3d-1.0.0-Linux-x86_64.tar.gz" \
    | tar -xzC /opt/c3d --strip-components 1
ENV C3DPATH /opt/c3d/
ENV PATH $C3DPATH/bin:$PATH

# install miniconda
RUN wget -q http://repo.continuum.io/miniconda/Miniconda-3.8.3-Linux-x86_64.sh && \
    bash Miniconda-3.8.3-Linux-x86_64.sh -b -p /usr/local/miniconda && \
    rm Miniconda-3.8.3-Linux-x86_64.sh

# update path to include conda
ENV PATH=/usr/local/miniconda/bin:$PATH

# install conda dependencies
RUN conda install -y \
      cython \
      ipython \
      jinja2==2.7.2 \
      matplotlib \
      networkx==1.11 \
      nose \
      numpy==1.11 \
      pandas \
      pip \
      pyyaml \
      scipy \
      traits \
      wxpython

# install python dependencies
RUN pip install \
      boto3 \
      configparser \
      fs==0.5.4 \
      future==0.15.2 \
      lockfile \
      memory_profiler \
      nibabel \
      nipype==0.13.1 \
      patsy \
      psutil \
      prov \
      pygraphviz \
      simplejson

RUN pip install git+https://github.com/ccraddock/INDI-Tools.git

# install AFNI
COPY required_afni_pkgs.txt /opt/required_afni_pkgs.txt
RUN libs_path=/usr/lib/x86_64-linux-gnu && \
    if [ -f $libs_path/libgsl.so.19 ]; then \
           ln $libs_path/libgsl.so.19 $libs_path/libgsl.so.0; \
    fi && \
    mkdir -p /opt/afni && \
    wget -q http://afni.nimh.nih.gov/pub/dist/tgz/linux_openmp_64.tgz && \
    tar zxv -C /opt/afni --strip-components=1 -f linux_openmp_64.tgz $(cat /opt/required_afni_pkgs.txt) && \
    rm -rf linux_openmp_64.tgz

# set up afni
ENV PATH=/opt/afni:$PATH

# install FSL
RUN apt-get update  && \
    apt-get install -y --no-install-recommends \
                    fsl-core \
                    fsl-atlases \
                    fsl-mni152-templates

# setup fsl environment
ENV FSLDIR=/usr/share/fsl/5.0 \
    FSLOUTPUTTYPE=NIFTI_GZ \
    FSLMULTIFILEQUIT=TRUE \
    POSSUMDIR=/usr/share/fsl/5.0 \
    LD_LIBRARY_PATH=/usr/lib/fsl/5.0:$LD_LIBRARY_PATH \
    FSLTCLSH=/usr/bin/tclsh \
    FSLWISH=/usr/bin/wish \
    PATH=/usr/lib/fsl/5.0:$PATH

# install ANTs
RUN apt-get update && \
    apt-get install -y \
    ants

# install cpac resources
RUN cd /tmp && \
    wget -q http://fcon_1000.projects.nitrc.org/indi/cpac_resources.tar.gz && \
    tar xfz cpac_resources.tar.gz && \
    cd cpac_image_resources && \
    cp -n MNI_3mm/* $FSLDIR/data/standard && \
    cp -n MNI_4mm/* $FSLDIR/data/standard && \
    cp -n symmetric/* $FSLDIR/data/standard && \
    cp -nr tissuepriors/2mm $FSLDIR/data/standard/tissuepriors && \
    cp -nr tissuepriors/3mm $FSLDIR/data/standard/tissuepriors && \
    cp -n HarvardOxford-lateral-ventricles-thr25-2mm.nii.gz $FSLDIR/data/atlases/HarvardOxford

# install cpac templates
COPY cpac_templates.tar.gz /cpac_resources/cpac_templates.tar.gz
RUN cd cpac_resources && \
    tar xzvf /cpac_resources/cpac_templates.tar.gz && \
    rm -f /cpac_resources/cpac_templates.tar.gz
    
# install cpac
RUN pip install git+https://github.com/FCP-INDI/C-PAC.git@v1.1.0
#RUN pwd && pip install git+https://github.com/ccraddock/C-PAC.git

# make directory for nipype
RUN mkdir /.nipype && \
    chmod 777 /.nipype

# clean up
RUN apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# copy container scripts
COPY version /code/version
COPY bids_utils.py /code/bids_utils.py
COPY run.py /code/run.py

# make the run.py executable
RUN chmod +x /code/run.py

# copy useful pipeline scripts
COPY default_pipeline.yaml /cpac_resources/default_pipeline.yaml
COPY test_pipeline.yaml /cpac_resources/test_pipeline.yaml

ENTRYPOINT ["/code/run.py"]
