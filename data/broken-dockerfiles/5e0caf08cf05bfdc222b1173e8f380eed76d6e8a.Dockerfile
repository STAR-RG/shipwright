FROM jupyter/datascience-notebook

LABEL maintainer "Pedro Hernandez <p.hernandezserrano@maastrichtuniversity.nl>"

USER root

RUN apt-get update && \ 
    apt-get -y install wget python-pip libblas3 liblapack3 libstdc++6 python-setuptools && \
    apt-get clean 

USER $NB_UID

RUN pip install --process-dependency-links -U turicreate h5py keras

EXPOSE 8888

CMD ["start.sh", "jupyter", "lab", "--port=8888", "--no-browser", "--allow-root", "--ip=0.0.0.0"]
