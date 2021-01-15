FROM continuumio/miniconda3
MAINTAINER WFP VAM "vam.info@wfp.org"

ADD . /app
WORKDIR /app

RUN conda env create -n eee -f /app/environment.yml
# Pull the environment name out of the environment.yml
RUN echo "source activate eee" > ~/.bashrc
ENV PATH /opt/conda/envs/eee/bin:$PATH

ENTRYPOINT ["python","scripts/master.py"]