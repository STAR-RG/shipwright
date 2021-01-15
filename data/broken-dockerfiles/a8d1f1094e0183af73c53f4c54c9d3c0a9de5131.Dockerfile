FROM nvidia/cuda:9.0-devel-ubuntu16.04
LABEL maintainer "Wamsi Viswanath [https://www.linkedin.com/in/wamsiv]"

ENV MAPD_ML=mapd_ml_examples

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
            ca-certificates \
            wget \
            build-essential \
            libopenblas-dev \
            bzip2 \
            git && \
            apt-get remove --purge -y && \
            rm -rf /var/lib/apt/lists/*

# Install Miniconda
WORKDIR /opt/conda

RUN wget --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh -O /opt/conda/miniconda3.sh
RUN bash /opt/conda/miniconda3.sh -b -p /opt/conda/Miniconda3
ENV PATH=$PATH:/opt/conda/Miniconda3/bin

# Copy files
COPY . /mapd-ml
WORKDIR /mapd-ml

# Create Environment
RUN conda update conda && conda env create -n $MAPD_ML -f /mapd-ml/env/py36_example.yml

# Add h2o4gpu
RUN wget https://s3.amazonaws.com/h2o-release/h2o4gpu/releases/stable/ai/h2o/h2o4gpu/0.2-nccl-cuda8/h2o4gpu-0.2.0-cp36-cp36m-linux_x86_64.whl && \
    pip install --upgrade pip && pip install h2o4gpu-0.2.0-cp36-cp36m-linux_x86_64.whl && rm -rf h2o4gpu-0.2.0-cp36-cp36m-linux_x86_64.whl

EXPOSE 8888

CMD bash ./utils/start_demo_notebook.sh
