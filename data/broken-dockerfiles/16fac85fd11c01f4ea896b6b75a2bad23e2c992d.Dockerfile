FROM ubuntu:16.04

LABEL mantainer="Eloy Lopez <elswork@gmail.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    libfreetype6-dev \
    libpng12-dev \
    libzmq3-dev \
    pkg-config \
    python \
    python-dev \
    python-pip \
    python-setuptools \
    python-scipy \
    rsync \
    software-properties-common \
    unzip \
    git \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

 RUN python -m pip install --upgrade pip && \
  pip --no-cache-dir install \
     ipykernel \
     jupyterlab \
     matplotlib \
     numpy \
     sklearn \
     pandas \
     && \
     python -m ipykernel.kernelspec

ARG WHL_URL=http://ci.tensorflow.org/view/Nightly/job/nightly-pi/lastSuccessfulBuild/artifact/output-artifacts/
ARG WHL_FILE=tensorflow-1.8.0-cp27-none-linux_armv7l.whl

RUN pip --no-cache-dir install ${WHL_URL}${WHL_FILE} && \
    rm -f ${WHL_FILE}	

COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
COPY notebooks /notebooks

# TensorBoard & Jupyter
EXPOSE 6006 8888

WORKDIR "/notebooks"

CMD jupyter lab --ip=* --no-browser --allow-root