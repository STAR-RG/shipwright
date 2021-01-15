FROM nvidia/cuda:8.0-cudnn5-devel

ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

RUN mkdir -p $CONDA_DIR && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget git libhdf5-dev g++ graphviz && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh && \
    echo "c59b3dd3cad550ac7596e0d599b91e75d88826db132e4146030ef471bb434e9a *Miniconda3-4.2.12-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash /Miniconda3-4.2.12-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-4.2.12-Linux-x86_64.sh 

# install openslide & screen
RUN \
    apt-get install -y python-imaging \
    	libopenjpeg-dev \
    	libsqlite3-dev \
    	python3-openslide \
    	python3-tk \
    	openslide-tools \
    	screen \
        vim

# install node.js node npm 
RUN \
    curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
    apt-get install -y nodejs 

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y npm
    
RUN \
    npm install -g n && \
    n stable

ENV NB_USER keras
ENV NB_UID 1000

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown keras $CONDA_DIR -R && \
    mkdir -p /src && \
    chown keras /src

USER keras

# install Python 3.5 & tensorflow-gpu & openslide
ARG python_version=3.5

RUN conda install -y python=${python_version} && \
    pip install --upgrade pip && \
    pip install flask && \
    pip install flask-cors && \
    pip install openslide-python && \
    pip install tensorflow-gpu && \
    conda install Pillow scikit-learn notebook pandas matplotlib mkl nose pyyaml six h5py && \
    conda install theano pygpu && \
    git clone git://github.com/fchollet/keras.git /src && pip install -e /src[tests] && \
    pip install git+git://github.com/fchollet/keras.git && \
    conda clean -yt

# ADD theanorc /home/keras/.theanorc

ENV PYTHONPATH='/src/:$PYTHONPATH'

# WORKDIR /src  最好不用这个工作目录，因为 notebook 会以这个为根目录
WORKDIR /

EXPOSE 8888
EXPOSE 8081
EXPOSE 5000

CMD jupyter notebook --port=8888 --ip=0.0.0.0
