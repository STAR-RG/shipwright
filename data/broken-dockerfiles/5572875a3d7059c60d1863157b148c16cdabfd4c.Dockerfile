FROM arwineap/docker-ubuntu-python3.6

RUN apt-get update

# Install latest version of python3
RUN apt install -y python3.6
RUN pip install --upgrade setuptools
RUN apt-get install -y python3.6-dev build-essential
RUN apt-get install -y libblas-dev libatlas-base-dev

# Upgrade pip
RUN pip install --upgrade pip

RUN apt-get install -y python3-tk
RUN apt install -y libglib2.0-0
RUN apt install -y libsm6 libxext6

# Install bindsnet and dependencies
RUN pip install bindsnet

# Install git
RUN apt-get install -y git-core

# Install vim
RUN apt install -y vim 
RUN pip install jupyter -U && pip install jupyterlab

# Bind python3.6 to python
RUN touch ~/.bash_aliases
RUN echo alias python=\'/usr/bin/python3.6\' >> ~/.bash_aliases

# Create a working directory to work from
RUN mkdir working

# Always start from /working
RUN chmod 777 \/working
ENTRYPOINT ["/working"]

