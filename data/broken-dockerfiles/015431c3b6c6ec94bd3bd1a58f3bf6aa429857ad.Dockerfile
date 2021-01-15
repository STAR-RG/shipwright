FROM nvidia/cuda:9.0-cudnn7-runtime-ubuntu16.04

MAINTAINER luca.grazioli@outlook.com

RUN apt-get update && apt-get install -y \
	wget \
	vim \
	bzip2

#Downgrade CUDA, TF issue: https://github.com/tensorflow/tensorflow/issues/17566#issuecomment-372490062
RUN apt-get install --allow-downgrades -y libcudnn7=7.0.5.15-1+cuda9.0

#Install MINICONDA
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda.sh && \
	/bin/bash Miniconda.sh -b -p /opt/conda && \
	rm Miniconda.sh

ENV PATH /opt/conda/bin:$PATH

#Install ANACONDA Environment
RUN conda create -y -n jupyter_env python=3.6 anaconda && \
	/opt/conda/envs/jupyter_env/bin/pip install tensorflow-gpu keras jupyter-tensorboard jupyterlab

#Launch JUPYTER COMMAND
CMD /opt/conda/envs/jupyter_env/bin/jupyter notebook --ip=* --no-browser --allow-root --notebook-dir=/tmp
