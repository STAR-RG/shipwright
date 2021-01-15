# SOURCE IMAGE
FROM ubuntu

LABEL maintainer="Mihai Criveti"
LABEL name="cmihai/jupyter"
LABEL version="1.0"

# ENVIRONMENT
ENV LANGUAGE=en_US.UTF-8 LANG=C.UTF-8 LC_ALL=C.UTF-8 PYTHONIOENCODING=UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# INSTALL OS PACKAGES
RUN apt-get update && apt-get --quiet --yes install \
    wget curl bzip2 build-essential git sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# SWITCH TO REGULAR USER
RUN useradd -m -s /bin/bash -N jupyter
USER jupyter
ENV HOME=/home/jupyter \
    PATH=/home/jupyter/anaconda3/bin:$PATH \
    CONDA_DIR=/home/jupyter/anaconda3

# INSTALL MINICONDA
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/conda-install.sh \
    && bash /tmp/conda-install.sh -b -p $HOME/anaconda3 > /tmp/conda-install.log 2>&1 \
    && echo 'export PATH="/home/jupyter/anaconda3/bin:$PATH"' >> ~/.bashrc \
    && rm /tmp/conda-install.sh

# INSTALL CONDA PACKAGES
RUN conda update --yes conda && conda update --yes --all
RUN conda install --quiet --yes requests pylint \
    jupyter ipywidgets \
    numpy pandas statsmodels matplotlib scrapy xlrd nltk redis \
    scipy scikit-learn
RUN conda install -y conda=4.4.7
RUN conda install --yes --channel conda-forge autopep8 matplotlib-venn \
    jupyter_nbextensions_configurator jupyter_contrib_nbextensions beakerx
RUN conda install --yes --channel pytorch pytorch-cpu torchvision
RUN conda clean --yes --all
RUN pip install --upgrade tensorflow

# PERSISTENCE
VOLUME ["/home/jupyter/notebooks"]
VOLUME ["/home/jupyter/.jupyter"]

# WORKDIR
WORKDIR /home/jupyter/notebooks

# COMMAND and ENTRYPOINT:
CMD ["/home/jupyter/anaconda3/bin/jupyter","notebook","--ip=0.0.0.0","--port=8888"]

# NETWORK
EXPOSE 8888
