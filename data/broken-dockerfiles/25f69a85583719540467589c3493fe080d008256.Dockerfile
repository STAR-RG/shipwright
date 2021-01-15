# Matias Carrasco Kind
# mcarras2@illinos.edu
# Dockerfile for easyaccess
#

FROM continuumio/miniconda3
RUN apt-get update
RUN apt-get install -y libaio1
RUN conda create -n env python=3.6
RUN echo "source activate env" > ~/.bashrc
ENV PATH /opt/conda/envs/env/bin:$PATH
RUN conda install --yes -c anaconda -c mgckind easyaccess==1.4.7
RUN useradd --create-home --shell /bin/bash des --uid 1001
WORKDIR /home/des
USER des
ENV PATH /opt/conda/envs/env/bin:$PATH
ENV HOME /home/des
